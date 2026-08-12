return {
  'saghen/blink.cmp',
  dependencies = {
    'saghen/blink.lib',
    'rafamadriz/friendly-snippets',
  },
  -- Build the Rust matcher locally instead of downloading the prebuilt one:
  -- upstream's release binaries have a 4-mod-8 __LINKEDIT string pool that
  -- macOS 26's dyld refuses to load. The script rebuilds and realigns it.
  build = function(plugin)
    local script = vim.fn.stdpath('config') .. '/scripts/build-blink-fuzzy.sh'
    local out = vim.system({ 'sh', script, plugin.dir }, { text = true }):wait(300000)
    if out.code ~= 0 then
      error('blink fuzzy build failed:\n' .. (out.stderr or '') .. (out.stdout or ''))
    end
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
