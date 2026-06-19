-- Auto-continue markdown/text lists: pressing Enter (or o/O) continues the
-- bullet, increments ordered lists, and clearing an empty item ends the list.
-- Editing commands recalculate ordered numbering automatically.
return {
  "gaoDean/autolist.nvim",
  ft = { "markdown", "text", "tex", "plaintex", "norg" },
  config = function()
    local fts = { "markdown", "text", "tex", "plaintex", "norg" }

    require("autolist").setup()

    -- Buffer-local so other filetypes (and blink/mini.pairs <CR> elsewhere)
    -- are untouched.
    local function set_maps(buf)
      local function bmap(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true })
      end
      -- Continue / increment / clear-empty on Enter. The leading <CR> is a
      -- plain newline (non-recursive), so it never re-enters this mapping.
      bmap("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
      -- New bullets from normal mode.
      bmap("n", "o", "o<cmd>AutolistNewBullet<cr>")
      bmap("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
      -- Toggle a checkbox on the current line with Enter in normal mode.
      bmap("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
      -- Keep ordered numbering correct after structural edits.
      bmap("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")
      bmap("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
      bmap("v", "d", "d<cmd>AutolistRecalculate<cr>")
      bmap("n", ">>", ">><cmd>AutolistRecalculate<cr>")
      bmap("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_autolist", { clear = true }),
      pattern = fts,
      callback = function(ev) set_maps(ev.buf) end,
    })
    -- Apply to the buffer that triggered plugin loading (missed by the autocmd).
    if vim.tbl_contains(fts, vim.bo.filetype) then
      set_maps(0)
    end
  end,
}
