require("config.lazy")
require("config.keymaps")

math.randomseed(os.time())

vim.cmd("colorscheme blackwhite")

vim.opt.fillchars = "eob: "
vim.opt.clipboard = "unnamedplus"
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

if vim.g.neovide then
  vim.o.guifont = "Maple Mono NF:h18"
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.9
end
