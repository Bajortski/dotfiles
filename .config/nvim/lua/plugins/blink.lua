return {
  'saghen/blink.cmp',
  dependencies = {
    'saghen/blink.lib',
    'rafamadriz/friendly-snippets',
    'milanglacier/minuet-ai.nvim',
  },
  build = function()
    require('blink.cmp').build():pwait(60000)
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ["<Tab>"] = {
        function(cmp)
          local ok, vt = pcall(require, 'minuet.virtualtext')
          if not ok then return false end
          if vt.action.is_visible() then
            vt.action.accept()
            return true
          end
          return cmp.accept()
        end,
        "fallback",
      },
      ["<CR>"] = { "fallback" },
    },

    completion = {
      documentation = { auto_show = false },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = "prefer_rust" },
  },
}
