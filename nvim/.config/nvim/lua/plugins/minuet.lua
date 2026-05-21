return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      request_timeout = 10,
      provider = 'openai_compatible',
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
      provider_options = {
        openai_compatible = {
          model = 'mistral:7b',
          end_point = 'http://localhost:11434/v1/chat/completions',
          api_key = 'TERM',
          name = 'Ollama',
          stream = false,
          system = {
            prompt = [[
You are a writing assistant. Predict the next 1-5 words of the given English text naturally, maintaining the author's voice and style. Provide only the completion text itself — no explanations, commentary, or markdown formatting. Keep completions concise, short, and in one line.
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
