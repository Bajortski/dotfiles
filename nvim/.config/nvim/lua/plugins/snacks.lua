local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = require("util.random_quote").from_markdown("~/.config/nvim/quotes.md"),
        keys = {
          { icon = "󰍉", key = "f", desc = "search", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "", key = "n", desc = "create new file", action = ":ene | startinsert" },
          { icon = "", key = "p", desc = "projects", action = ":lua Snacks.picker.projects()" },
          { icon = "󱋢", key = "r", desc = "browse recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = "",
            key = "c",
            desc = "browse config files",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          {
            icon = "󱎮",
            key = "J",
            desc = "journal today",
            action = function()
              local year = os.date("%Y")
              local today = os.date("%Y-%m-%d")
              local path = vim.fn.expand("~/Documents/Vaulternative/Journal/" .. today .. ".md")
              local dir = vim.fn.fnamemodify(path, ":h")
              if vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, "p")
              end
              vim.cmd("edit " .. path)
            end,
          },
          { icon = "󰋚", key = "s", desc = "restore last session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "lazy", action = ":Lazy" },
          { icon = "󰠚", key = "q", desc = "quit", action = ":q!" },
        },
      },
      sections = {
        { section = "header", align = "center" },
        { section = "keys", gap = 1 },
      },
    },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
  },
}