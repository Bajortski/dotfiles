-- load config files: lazy, options, keymaps, neovide
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.neovide")

-- set randomseed for launchpad quote
math.randomseed(os.time())

--set theme
vim.cmd("colorscheme blackwhite")
