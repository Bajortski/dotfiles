-- File explorer is neo-tree (see neo-tree.lua). Snacks keeps its explorer module
-- available but does not bind <leader>e/<leader>fe, to avoid clobbering neo-tree.
return {
  desc = "Snacks File Explorer",
  recommended = true,
  "folke/snacks.nvim",
  opts = { explorer = {} },
}
