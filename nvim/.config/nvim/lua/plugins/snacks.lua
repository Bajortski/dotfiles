return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = require("util.random_quote").from_markdown("~/.config/nvim/quotes.md"),
        keys = {
          { icon = " ", key = "f", desc = "search", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "create new file", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "search text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "browse recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "browse config files",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          {
            icon = " ",
            key = "j",
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
          { icon = " ", key = "s", desc = "restore last session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "lazy", action = ":Lazy" },
          { icon = "⏻", key = "q", desc = "quit", action = ":q!" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1 },
      },
    },
  },
}
