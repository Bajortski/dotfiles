-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

math.randomseed(os.time())
local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.cmd("colorscheme blackwhite")

if vim.g.neovide then
  vim.o.guifont = "Maple Mono NF"
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.9
end

local strudel = require("strudel")
vim.keymap.set("n", "<leader>sl", strudel.launch, { desc = "Launch Strudel" })
vim.keymap.set("n", "<leader>sq", strudel.quit, { desc = "Quit Strudel" })
vim.keymap.set("n", "<leader>st", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
vim.keymap.set("n", "<leader>su", strudel.update, { desc = "Strudel Update" })
vim.keymap.set("n", "<leader>ss", strudel.stop, { desc = "Strudel Stop Playback" })
vim.keymap.set("n", "<leader>sb", strudel.set_buffer, { desc = "Strudel set current buffer" })
vim.keymap.set("n", "<leader>sx", strudel.execute, { desc = "Strudel set current buffer and update" })
