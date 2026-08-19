-- cotyper: always-on inline autocomplete (Cotypist-style). Ghost text as you type;
-- Tab (see blink.lua) accepts it word-by-word. Learns from your markdown + gemma4.
-- https://github.com/Bajortski/cotyper.nvim
return {
  "Bajortski/cotyper.nvim",
  event = "InsertEnter",
  opts = {
    -- gemma4 via Ollama (run: ollama pull gemma4:e2b-mlx). Set llm=false to skip it.
    model = "gemma4:e2b-mlx",
    filetypes = { "markdown" },
    -- Keep a separate learned style guide per note tag, read from frontmatter `tags:`.
    -- A note with several tags is filed under whichever the most vault notes use.
    style_by_tag = true,
    -- Personal style/voice, appended to the plugin's general prompt. Edit this freely.
    style = table.concat({
      "My name is Toast. I usually write in English.",
      "Please use British English (e.g. Colour) spelling and punctuation, with the exception of '-ise' spelling. Do not use '-ise', use 'ize'.",
      "Write in a clear, sardonic voice. Keep your sentences short, concise and readable.",
    }, " "),
  },
  config = function(_, opts)
    require("cotyper").setup(opts)
  end,
}
