-- fff.nvim: fast Rust-backed file picker + live grep. Replaces the snacks *file finding
-- and grep* keymaps (buffers, git, LSP, diagnostics, etc. stay on snacks — see
-- snacks_picker.lua). https://github.com/dmtrKovalenko/fff.nvim
local VAULT = vim.fn.expand("~/Documents/Vaulternative")

local function in_vault()
  local bufpath = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  return vim.startswith(bufpath, vim.fs.normalize(VAULT) .. "/")
end

-- Search root: the Obsidian vault when editing a vault file, otherwise the git/project
-- root (or cwd when `force_cwd`). Mirrors the old snacks `pick()` rooting.
local function root(force_cwd)
  if in_vault() then
    return VAULT
  end
  if force_cwd then
    return vim.fn.getcwd()
  end
  return vim.fs.root(0, { ".git", ".hg", ".svn" }) or vim.fn.getcwd()
end

local function files(force_cwd)
  return function()
    require("fff").find_files({ cwd = root(force_cwd) })
  end
end

local function grep(force_cwd)
  return function()
    require("fff").live_grep({ cwd = root(force_cwd) })
  end
end

return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false, -- fff indexes files in the background; load at startup
  opts = {
    prompt = '> ',
    title = 'FFF',
    prompt_vim_mode = true,
    enable_home_dir_scanning = true,
    layout = {
      prompt_position = 'top',
      border = 'rounded',
    },
  },
  -- stylua: ignore
  keys = {
    -- files (root = vault/git-root; cwd = current working dir)
    { "<leader><space>", files(true),                                                     desc = "Find Files (cwd)" },
    { "<leader>ff",      files(false),                                                    desc = "Find Files (Root Dir / Vault)" },
    { "<leader>fF",      function() require("fff").find_files({ cwd = vim.fn.expand("~") }) end,        desc = "Find Files (Global)" },
    { "<leader>fc",      function() require("fff").find_files({ cwd = vim.fn.stdpath("config") }) end,  desc = "Find Config File" },
    -- grep
    { "<leader>/",       grep(false),                                                     desc = "Grep (Root Dir / Vault)" },
    { "<leader>sg",      grep(false),                                                     desc = "Grep (Root Dir / Vault)" },
    { "<leader>sG",      grep(true),                                                      desc = "Grep (cwd / Vault)" },
    { "<leader>sw",      function() require("fff").live_grep_under_cursor({ cwd = root(false) }) end, mode = { "n", "x" }, desc = "Grep word (Root Dir)" },
    { "<leader>sW",      function() require("fff").live_grep_under_cursor({ cwd = root(true) })  end, mode = { "n", "x" }, desc = "Grep word (cwd)" },
  }
}
