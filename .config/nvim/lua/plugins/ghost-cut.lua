-- Ghost cut: cut text stays dimmed in place (no reflow) until you paste it
-- elsewhere. https://github.com/Bajortski/ghost-cut.nvim
return {
  "Bajortski/ghost-cut.nvim",
  keys = {
    { "gx", mode = "x", desc = "Ghost cut selection" },
  },
  -- The plugin defaults to gX (gx is Neovim's built-in "open with system app"),
  -- but that built-in is normal-mode only, so visual gx is free to reuse here.
  opts = { cut_key = "gx" },
  config = function(_, opts)
    require("ghost-cut").setup(opts)
  end,
}
