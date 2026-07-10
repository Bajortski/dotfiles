return {
  'saghen/blink.cmp',
  dependencies = {
    'saghen/blink.lib',
    'rafamadriz/friendly-snippets',
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
          -- When cotyper has a ghost, Tab accepts it one word at a time.
          local ok, ct = pcall(require, 'cotyper')
          if ok and ct.is_visible() then
            ct.accept_word()
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
