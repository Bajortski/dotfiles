-- Obsidian Sync state, for the statusline.
--
-- Obsidian Sync is a service inside the Obsidian app: it has no external API,
-- writes no state file into the vault, and logs nothing about itself (the app's
-- obsidian.log only records updater events). So this INFERS state from the two
-- things visible from outside:
--
--   1. Whether Obsidian is running at all. Sync only runs inside the app, so a
--      closed Obsidian means edits made here are going nowhere yet.
--   2. When Obsidian last wrote to its IndexedDB, versus when we last saved a
--      vault file from Neovim. If our write is newer, Obsidian hasn't picked it
--      up; once its DB moves past our write, it has.
--
-- That answers the question that actually matters when editing vault notes in
-- Neovim: "is anything going to pick this edit up?" It cannot distinguish a
-- sync upload from any other Obsidian write — see `syncing` below.

local M = {}

local uv = vim.uv or vim.loop

M.config = {
  vault = vim.fn.expand("~/Documents/Vaulternative"),
  -- Obsidian's IndexedDB directory. Its mtime moves whenever the app writes.
  db = vim.fn.expand(
    "~/Library/Application Support/obsidian/IndexedDB/app_obsidian.md_0.indexeddb.leveldb"
  ),
  -- macOS process name, as matched by `pgrep -x`.
  process = "Obsidian",
  -- How often to re-check, in ms. Each poll is one stat plus one pgrep.
  interval = 4000,
  -- A DB write newer than this many seconds counts as "actively working".
  active_window = 8,
}

-- Display for each state. `hl` names a highlight group resolved at render time.
local DISPLAY = {
  off     = { icon = "", text = "sync off",  hl = "DiagnosticError" },
  unsynced= { icon = "", text = "unsynced",  hl = "DiagnosticWarn" },
  syncing = { icon = "", text = "syncing",   hl = "DiagnosticInfo" },
  synced  = { icon = "", text = "synced",    hl = "DiagnosticOk" },
  unknown = { icon = "", text = "sync ?",    hl = "Comment" },
}

-- Latest computed state, read by the statusline component.
M.state = "unknown"
-- Time we last saved a file inside the vault, so we can tell whether Obsidian
-- has caught up with us. nil = we haven't touched the vault this session.
M.last_write = nil

local timer = nil
local running = nil -- last known "is Obsidian running", nil until first poll

--- Is `path` inside the vault?
---@param path string|nil
---@return boolean
function M.in_vault(path)
  if not path or path == "" then return false end
  return vim.startswith(vim.fs.normalize(path), vim.fs.normalize(M.config.vault))
end

--- Is the current buffer a vault file?
function M.current_in_vault()
  return M.in_vault(vim.api.nvim_buf_get_name(0))
end

--- Seconds since Obsidian last wrote its database, or nil if it isn't there.
local function db_age()
  local st = uv.fs_stat(M.config.db)
  if not st then return nil end
  return os.time() - st.mtime.sec, st.mtime.sec
end

--- Recompute M.state from the cached `running` flag plus fresh mtimes.
local function recompute()
  if running == false then
    M.state = "off"
    return
  end
  if running == nil then
    M.state = "unknown"
    return
  end

  local age, db_time = db_age()
  if not age then
    M.state = "unknown"
  elseif M.last_write and db_time < M.last_write then
    -- We saved a vault file more recently than Obsidian has written anything,
    -- so our edit hasn't been ingested (let alone uploaded) yet.
    M.state = "unsynced"
  elseif age <= M.config.active_window then
    M.state = "syncing"
  else
    M.state = "synced"
  end
end

--- Poll once, asynchronously. Cheap: one stat plus one short-lived process.
function M.poll()
  vim.system({ "pgrep", "-x", M.config.process }, { text = true }, function(out)
    -- Runs in a fast-event context, so bounce to the main loop before touching
    -- state that the statusline reads.
    vim.schedule(function()
      local was = M.state
      running = out.code == 0
      recompute()
      if M.state ~= was then
        pcall(function() require("lualine").refresh() end)
      end
    end)
  end)
end

--- Start polling (idempotent). Only runs while a vault buffer is current, so a
--- normal coding session never spawns anything.
function M.start()
  if timer then return end
  timer = uv.new_timer()
  timer:start(0, M.config.interval, function()
    vim.schedule(function()
      if M.current_in_vault() then
        M.poll()
      else
        M.stop()
      end
    end)
  end)
end

function M.stop()
  if not timer then return end
  timer:stop()
  timer:close()
  timer = nil
end

--- The lualine component: a rendered, highlighted string (empty outside the
--- vault, so it costs nothing in other buffers).
function M.component()
  if not M.current_in_vault() then return "" end
  M.start()
  local d = DISPLAY[M.state] or DISPLAY.unknown
  return string.format("%%#%s#%s %s%%*", d.hl, d.icon, d.text)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  local grp = vim.api.nvim_create_augroup("obsidian_sync_status", { clear = true })

  -- Saving a vault file is the event that makes state interesting: from here
  -- until Obsidian writes again, the edit is unsynced.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = grp,
    callback = function(ev)
      if not M.in_vault(ev.file) then return end
      M.last_write = os.time()
      M.state = "unsynced"
      M.start()
      pcall(function() require("lualine").refresh() end)
    end,
  })

  -- Entering a vault buffer starts polling; leaving it lets the timer retire.
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
    group = grp,
    callback = function()
      if M.current_in_vault() then M.start() end
    end,
  })

  -- Raw signals, for checking the inference against reality.
  vim.api.nvim_create_user_command("ObsidianSyncDebug", function()
    local age, db_time = db_age()
    print(table.concat({
      "state:       " .. M.state,
      "in vault:    " .. tostring(M.current_in_vault()),
      "running:     " .. tostring(running),
      "db mtime:    " .. (db_time and os.date("%Y-%m-%d %H:%M:%S", db_time) or "missing"),
      "db age (s):  " .. tostring(age),
      "last write:  " .. (M.last_write and os.date("%Y-%m-%d %H:%M:%S", M.last_write) or "none"),
      "polling:     " .. tostring(timer ~= nil),
    }, "\n"))
  end, { desc = "Show the raw signals behind the Obsidian sync indicator" })
end

return M
