require("config.lazy")

math.randomseed(os.time())
local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.cmd("colorscheme blackwhite")

if vim.g.neovide then
  vim.o.guifont = "Maple Mono NF"
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.9
end
