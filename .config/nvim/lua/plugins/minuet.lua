return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      request_timeout = 30,
      provider = 'openai_compatible',
      -- Don't auto-trigger the inline suggestion at the start of a line or on a
      -- blank line (i.e. when there's only whitespace before the cursor).
      enable_predicates = {
        function()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          return vim.api.nvim_get_current_line():sub(1, col):find('%S') ~= nil
        end,
      },
      virtualtext = {
        auto_trigger_ft = { 'markdown' },
        keymap = {
          accept = '<C-Tab>',
          accept_line = '<A-a>',
          prev = '<A-[>',
          next = '<A-]>',
          dismiss = '<A-e>',
        },
      },
			n_completions = 1,
			context_window = 512,
			throttle = 100,
			debounce = 100,
      provider_options = {
        openai_compatible = {
          model = 'mistral:7b',
          end_point = 'http://localhost:11434/v1/chat/completions',
          api_key = 'TERM',
          name = 'Ollama',
          stream = false,
          system = {
            prompt = [[
You are a writing assistant completing writing in the style of the author. Predict the next sentence (or end of the current sentence if it makes sense) of the given English text naturally, maintaining the author's voice and style. Avoid hedging language, filler phrases and sentimental constructions. Continue the existing line of thought. Provide only the completion text itself, no commentary. Do not write lists. Keep your completions to a single line (do not ever make new lines) and one sentence. Follow grammatical conventions when starting a sentence, do not capitalize your completions if you are not starting a sentence. Do not use the Oxford comma.
            ]],
          },
          optional = {
            max_tokens = 5,
            top_p = 0.9,
          },
        },
      },
    }
  end,
}
