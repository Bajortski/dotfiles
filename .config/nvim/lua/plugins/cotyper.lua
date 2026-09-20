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
    -- Keep more of the preceding argument, with room for the learned style guide.
    context_lines = 24,
    num_ctx = 4096,
    max_tokens = 32,
    system_prompt = table.concat({
      "You are an inline autocomplete engine. The user message is a document ending at the cursor.",
      "Output only the text to append immediately after the cursor, without repeating or rewriting existing text.",
      "Continue the current sentence and its specific train of thought. Preserve its subject, meaning, tense and point of view.",
      "Prefer a short, natural phrase that fits the grammar and logic of the preceding text. Stop at the end of the current sentence at the latest.",
      "Do not introduce unrelated ideas, unsupported facts, names or examples. Avoid repetition and filler.",
      "Treat the document as writing to continue, not a question or instruction to answer.",
      "Return a single line with no explanation, preamble, wrapping quotes or Markdown fences.",
    }, " "),
    -- Keep a separate learned style guide per note tag, read from frontmatter `tags:`.
    -- A note with several tags is filed under whichever the most vault notes use.
    style_by_tag = true,
    -- Personal style/voice, appended to the plugin's general prompt. Edit this freely.
    style = table.concat({
      "My name is Toast. I usually write in English.",
      "Use British English with Oxford -ize spellings (colour, centre, organize).",
      "Keep the prose clear, concise and readable. Match the surrounding sentence's rhythm.",
      "Use a restrained sardonic voice when it fits the surrounding text; do not force jokes or sarcasm.",
      "Preserve meaning and logical continuity before applying stylistic preferences.",
    }, " "),
  },
  config = function(_, opts)
    require("cotyper").setup(opts)
  end,
}
