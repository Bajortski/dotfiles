-- Obsidian template expansion, for notes created outside the app.
--
-- Obsidian's core templates use moment.js placeholders — {{date}}, {{time}} and
-- {{title}}, each taking an optional offset and format: {{date-1d:YYYY-MM-DD}}.
-- Those are expanded by the app at insert time, so a note created from Neovim
-- never gets them processed and ends up with the raw braces in the file. This
-- does the same expansion locally.
--
-- Placeholders that aren't ours (Templater's {{...}} syntax, say) are left
-- exactly as written rather than mangled.

local M = {}

M.config = {
  vault = vim.fn.expand("~/Documents/Vaulternative"),
  -- Template folder, matching the vault's .obsidian/templates.json.
  templates = "Templates",
  -- Fallbacks for a bare {{date}} / {{time}}, matching Obsidian's settings.
  date_format = "YYYY-MM-DD",
  time_format = "HH:mm",
}

local function pad(n, width)
  return string.format("%0" .. (width or 2) .. "d", n)
end

-- moment.js format tokens. Each takes the broken-down date plus the raw
-- timestamp, since month and day names are easiest to get from os.date.
local TOKENS = {
  YYYY = function(d) return tostring(d.year) end,
  YY = function(d) return pad(d.year % 100) end,
  MMMM = function(_, t) return os.date("%B", t) end,
  MMM = function(_, t) return os.date("%b", t) end,
  MM = function(d) return pad(d.month) end,
  M = function(d) return tostring(d.month) end,
  DDDD = function(d) return pad(d.yday, 3) end,
  DDD = function(d) return tostring(d.yday) end,
  DD = function(d) return pad(d.day) end,
  D = function(d) return tostring(d.day) end,
  dddd = function(_, t) return os.date("%A", t) end,
  ddd = function(_, t) return os.date("%a", t) end,
  dd = function(_, t) return os.date("%a", t):sub(1, 2) end,
  d = function(d) return tostring(d.wday - 1) end,
  -- ISO week number; moment spells it W/WW, Obsidian's docs also show w/ww.
  WW = function(_, t) return os.date("%V", t) end,
  W = function(_, t) return tostring(tonumber(os.date("%V", t))) end,
  ww = function(_, t) return os.date("%V", t) end,
  w = function(_, t) return tostring(tonumber(os.date("%V", t))) end,
  gggg = function(_, t) return os.date("%G", t) end,
  GGGG = function(_, t) return os.date("%G", t) end,
  HH = function(d) return pad(d.hour) end,
  H = function(d) return tostring(d.hour) end,
  hh = function(d) return pad(d.hour % 12 == 0 and 12 or d.hour % 12) end,
  h = function(d) return tostring(d.hour % 12 == 0 and 12 or d.hour % 12) end,
  mm = function(d) return pad(d.min) end,
  m = function(d) return tostring(d.min) end,
  ss = function(d) return pad(d.sec) end,
  s = function(d) return tostring(d.sec) end,
  SSS = function() return "000" end,
  A = function(d) return d.hour < 12 and "AM" or "PM" end,
  a = function(d) return d.hour < 12 and "am" or "pm" end,
  X = function(_, t) return tostring(t) end,
  ZZ = function(_, t) return os.date("%z", t) end,
}

-- Longest first, so MMMM is matched before MM before M.
local TOKEN_NAMES = vim.tbl_keys(TOKENS)
table.sort(TOKEN_NAMES, function(a, b) return #a > #b end)

--- Format a timestamp with a moment.js format string.
--- Text inside square brackets is passed through literally, as moment does.
---@param fmt string
---@param time integer
---@return string
local function moment(fmt, time)
  local d = os.date("*t", time)
  local out, i = {}, 1
  while i <= #fmt do
    local literal = fmt:sub(i, i) == "[" and fmt:find("]", i + 1, true)
    if literal then
      out[#out + 1] = fmt:sub(i + 1, literal - 1)
      i = literal + 1
    else
      local hit
      for _, name in ipairs(TOKEN_NAMES) do
        if fmt:sub(i, i + #name - 1) == name then
          hit = name
          break
        end
      end
      if hit then
        out[#out + 1] = TOKENS[hit](d, time)
        i = i + #hit
      else
        out[#out + 1] = fmt:sub(i, i)
        i = i + 1
      end
    end
  end
  return table.concat(out)
end

--- Last day of a month, for clamping.
local function days_in_month(year, month)
  -- Day 0 of the following month is the last day of this one.
  return os.date("*t", os.time({ year = year, month = month + 1, day = 0, hour = 12 })).day
end

--- Shift a timestamp by `n` of a moment unit (y M w d h m s).
--- Calendar units go through the date table rather than arithmetic on seconds,
--- so a day either side of a DST change still lands on the right date.
---@param time integer
---@param n integer
---@param unit string
---@return integer
local function shift(time, n, unit)
  if unit == "h" then return time + n * 3600 end
  if unit == "m" then return time + n * 60 end
  if unit == "s" then return time + n end

  local d = os.date("*t", time)
  d.isdst = nil -- let the C library work out DST for the shifted date
  if unit == "d" then
    d.day = d.day + n
  elseif unit == "w" then
    d.day = d.day + n * 7
  elseif unit == "M" or unit == "y" then
    local total = d.year * 12 + (d.month - 1) + (unit == "y" and n * 12 or n)
    d.year, d.month = math.floor(total / 12), total % 12 + 1
    -- moment clamps instead of rolling over: Jan 31 plus a month is Feb 28.
    d.day = math.min(d.day, days_in_month(d.year, d.month))
  end
  return os.time(d)
end

--- Expand one placeholder's contents, or nil if it isn't one we handle.
---@param inner string text between the braces
---@param now integer
---@param title string
---@return string|nil
local function expand(inner, now, title)
  local head, fmt = inner:match("^([^:]*):(.*)$")
  if not head then head = inner end
  head = vim.trim(head)

  local name, sign, count, unit = head:match("^(%a+)([+-])(%d+)([yMwdhms])$")
  name = name or head:match("^(%a+)$")
  if not name then return nil end

  name = name:lower()
  if name == "title" then return title end
  if name ~= "date" and name ~= "time" then return nil end

  local time = sign and shift(now, (sign == "-" and -1 or 1) * tonumber(count), unit) or now
  if not fmt or fmt == "" then
    fmt = name == "time" and M.config.time_format or M.config.date_format
  end
  return moment(fmt, time)
end

--- Expand every placeholder in a template's text.
---@param text string
---@param opts? { time?: integer, title?: string }
---@return string
function M.render(text, opts)
  opts = opts or {}
  local now = opts.time or os.time()
  local title = opts.title or ""
  return (text:gsub("{{(.-)}}", function(inner)
    local ok, out = pcall(expand, inner, now, title)
    if ok and out then return out end
    -- Not ours: hand back the braces untouched.
    return "{{" .. inner .. "}}"
  end))
end

--- Resolve a template name to a path. A bare name lands in the template folder;
--- anything containing a slash is taken as vault-relative; absolute wins.
---@param name string
---@return string
function M.resolve(name)
  local path = vim.fn.expand(name)
  if not path:match("%.md$") then
    path = path .. ".md"
  end
  if path:sub(1, 1) ~= "/" then
    local base = path:find("/", 1, true) and M.config.vault
      or (M.config.vault .. "/" .. M.config.templates)
    path = base .. "/" .. path
  end
  return path
end

--- Read a template and return its expanded lines, or nil if it's missing.
---@param name string
---@param opts? { time?: integer, title?: string }
---@return string[]|nil
function M.lines(name, opts)
  local path = M.resolve(name)
  if vim.fn.filereadable(path) == 0 then
    vim.notify("obsidian template not found: " .. path, vim.log.levels.WARN)
    return nil
  end
  local text = table.concat(vim.fn.readfile(path), "\n")
  return vim.split(M.render(text, opts), "\n", { plain = true })
end

--- The date a note is *about*, taken from a YYYY-MM-DD filename, or nil.
--- Offsets in a daily note should hang off the entry's own date, not the clock:
--- opening a backdated entry has to link the days either side of *it*. The time
--- of day stays current, so {{time}} still means now.
---@param title string
---@return integer|nil
local function date_from_title(title)
  local y, m, d = title:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
  if not y then return nil end
  local now = os.date("*t")
  return os.time({
    year = tonumber(y),
    month = tonumber(m),
    day = tonumber(d),
    hour = now.hour,
    min = now.min,
    sec = now.sec,
  })
end

--- Open `path`, seeding a brand-new file from `template`.
--- An existing note is opened untouched. The seeded buffer is left unwritten,
--- so backing out with :q! leaves no empty stub behind in the vault.
---@param path string
---@param template? string
---@param opts? { time?: integer }
function M.open(path, template, opts)
  path = vim.fn.expand(path)
  local fresh = vim.fn.filereadable(path) == 0

  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  vim.cmd.edit(vim.fn.fnameescape(path))

  if not fresh or not template then return end
  local title = vim.fn.fnamemodify(path, ":t:r")
  local lines = M.lines(template, {
    title = title,
    time = (opts or {}).time or date_from_title(title),
  })
  if not lines then return end

  -- Land the cursor on a blank line under the frontmatter block, ready to type.
  if lines[#lines] ~= "" then
    lines[#lines + 1] = ""
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { #lines, 0 })
end

return M
