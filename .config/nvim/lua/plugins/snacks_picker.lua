-- All file finding and grep lives here on snacks.picker: files, grep, word-grep,
-- buffers, recent, git, LSP, diagnostics, search, marks, etc. (The file explorer is
-- neo-tree; see neo-tree.lua.)
local VAULT = vim.fn.expand("~/Documents/Vaulternative")

local function in_vault()
  local bufpath = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  return vim.startswith(bufpath, vim.fs.normalize(VAULT) .. "/")
end

-- Search root for the "File Dir" finder: the whole vault when editing a vault note
-- (so notes stay browsable across folders), otherwise the current buffer's directory,
-- falling back to the working dir for unnamed/scratch buffers.
local function buf_dir()
  if in_vault() then
    return VAULT
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(name)
end

-- Wrap a Snacks picker source in a callable rooted to the vault (when editing a vault
-- file) or the git/project root, unless `opts.root == false`. Still used by non-file
-- pickers like recent.
local function pick(source, opts)
  opts = opts or {}
  return function()
    local o = vim.deepcopy(opts)
    if in_vault() then
      o.cwd = VAULT
    elseif o.root ~= false then
      o.cwd = vim.fs.root(0, { ".git", ".hg", ".svn" }) or vim.fn.getcwd()
    end
    o.root = nil
    Snacks.picker.pick(source, o)
  end
end

return {
  desc = "Fast and modern file picker",
  recommended = true,
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        -- Show dotfiles (e.g. .config, .gitignore) in file/grep results.
        -- `.gitignore`d files stay hidden; toggle them in-picker with <a-i>.
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          explorer = { hidden = true },
        },
        win = {
          input = {
            keys = {
              ["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } },
            },
          },
        },
        actions = {
          ---@param p snacks.Picker
          toggle_cwd = function(p)
            local root = vim.fs.normalize(
              vim.fs.root(p.input.filter.current_buf or 0, { ".git", ".hg", ".svn" })
              or vim.fn.getcwd()
            )
            local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
            local current = p:cwd()
            p:set_cwd(current == root and cwd or root)
            p:find()
          end,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,",       function() Snacks.picker.buffers() end,                                    desc = "Buffers" },
      { "<leader>:",       function() Snacks.picker.command_history() end,                             desc = "Command History" },
      { "<leader>n",       function() Snacks.picker.notifications() end,                              desc = "Notification History" },
      -- files (root = vault/git-root; cwd = current file's directory)
      { "<leader><space>", function() Snacks.picker.files({ cwd = buf_dir() }) end,                   desc = "Find Files (File Dir)" },
      { "<leader>ff",      pick("files"),                                                             desc = "Find Files (Root Dir / Vault)" },
      { "<leader>fF",      function() Snacks.picker.files({ cwd = vim.fn.expand("~") }) end,          desc = "Find Files (Global)" },
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,    desc = "Find Config File" },
      -- grep
      { "<leader>/",       pick("grep"),                                                              desc = "Grep (Root Dir / Vault)" },
      { "<leader>sg",      pick("grep"),                                                              desc = "Grep (Root Dir / Vault)" },
      { "<leader>sG",      function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end,              desc = "Grep (cwd)" },
      { "<leader>sw",      pick("grep_word"),                                    mode = { "n", "x" }, desc = "Grep Word (Root Dir / Vault)" },
      { "<leader>sW",      function() Snacks.picker.grep_word({ cwd = vim.fn.getcwd() }) end, mode = { "n", "x" }, desc = "Grep Word (cwd)" },
      -- find
      { "<leader>fb",      function() Snacks.picker.buffers() end,                                    desc = "Buffers" },
      { "<leader>fB",      function() Snacks.picker.buffers({ hidden = true, nofile = true }) end,    desc = "Buffers (all)" },
      { "<leader>fg",      function() Snacks.picker.git_files() end,                                  desc = "Find Files (git-files)" },
      { "<leader>fr",      pick("recent"),                                                             desc = "Recent" },
      { "<leader>fR",      function() Snacks.picker.recent({ filter = { cwd = true } }) end,          desc = "Recent (cwd)" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                                   desc = "Projects" },
      -- git
      { "<leader>gd",      function() Snacks.picker.git_diff() end,                                   desc = "Git Diff (hunks)" },
      { "<leader>gD",      function() Snacks.picker.git_diff({ base = "origin", group = true }) end,  desc = "Git Diff (origin)" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,                                 desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,                                  desc = "Git Stash" },
      { "<leader>gi",      function() Snacks.picker.gh_issue() end,                                   desc = "GitHub Issues (open)" },
      { "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end,                  desc = "GitHub Issues (all)" },
      { "<leader>gp",      function() Snacks.picker.gh_pr() end,                                      desc = "GitHub Pull Requests (open)" },
      { "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,                     desc = "GitHub Pull Requests (all)" },
      -- grep
      { "<leader>sb",      function() Snacks.picker.lines() end,                                      desc = "Buffer Lines" },
      { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                               desc = "Grep Open Buffers" },
      { "<leader>sp",      function() Snacks.picker.lazy() end,                                       desc = "Search for Plugin Spec" },
      -- search
      { '<leader>s"',      function() Snacks.picker.registers() end,                                  desc = "Registers" },
      { '<leader>s/',      function() Snacks.picker.search_history() end,                             desc = "Search History" },
      { "<leader>sa",      function() Snacks.picker.autocmds() end,                                   desc = "Autocmds" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,                            desc = "Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                                   desc = "Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,                                desc = "Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                         desc = "Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                                       desc = "Help Pages" },
      { "<leader>sH",      function() Snacks.picker.highlights() end,                                 desc = "Highlights" },
      { "<leader>si",      function() Snacks.picker.icons() end,                                      desc = "Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                                      desc = "Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                                    desc = "Keymaps" },
      { "<leader>sl",      function() Snacks.picker.loclist() end,                                    desc = "Location List" },
      { "<leader>sM",      function() Snacks.picker.man() end,                                        desc = "Man Pages" },
      { "<leader>sm",      function() Snacks.picker.marks() end,                                      desc = "Marks" },
      { "<leader>sR",      function() Snacks.picker.resume() end,                                     desc = "Resume" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                                     desc = "Quickfix List" },
      { "<leader>su",      function() Snacks.picker.undo() end,                                       desc = "Undotree" },
      -- lsp
      { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                                desc = "LSP Symbols" },
      { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                      desc = "LSP Workspace Symbols" },
      { "gd",              function() Snacks.picker.lsp_definitions() end,                            desc = "Goto Definition" },
      { "gr",              function() Snacks.picker.lsp_references() end,                             desc = "References",           nowait = true },
      { "gI",              function() Snacks.picker.lsp_implementations() end,                        desc = "Goto Implementation" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,                       desc = "Goto T[y]pe Definition" },
      { "gai",             function() Snacks.picker.lsp_incoming_calls() end,                         desc = "Calls Incoming" },
      { "gao",             function() Snacks.picker.lsp_outgoing_calls() end,                         desc = "Calls Outgoing" },
      -- ui
      { "<leader>uC",      function() Snacks.picker.colorschemes() end,                               desc = "Colorschemes" },
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local ok = pcall(require, "trouble")
      if ok then
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = {
              trouble_open = function(...)
                return require("trouble.sources.snacks").actions.trouble_open.action(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-t>"] = { "trouble_open", mode = { "n", "i" } },
                },
              },
            },
          },
        })
      end
    end,
  },
  {
    "folke/todo-comments.nvim",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  {
    "folke/flash.nvim",
    optional = true,
    specs = {
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"]     = { "flash" },
                },
              },
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
        },
      },
    },
  },
}
