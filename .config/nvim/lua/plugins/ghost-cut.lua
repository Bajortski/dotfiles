-- Ghost cut: cut text stays dimmed in place (no reflow) until you paste it
-- elsewhere. https://github.com/Bajortski/ghost-cut.nvim
return {
  "Bajortski/ghost-cut.nvim",
  keys = {
    { "gx", mode = "x", desc = "Ghost cut selection" },
  },
  opts = {},
  config = function(_, opts)
    require("ghost-cut").setup(opts)
  end,
}
