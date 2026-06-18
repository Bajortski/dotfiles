vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.g.colors_name = "blackwhite"
vim.o.termguicolors = true

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Palette
local black = "#000000"
local black_l5 = "#0D0D0D"
local black_l10 = "#1A1A1A"
local white = "#FFFFFF"
local white_d40 = "#9A9A9A"
local white_d50 = "#808080"
local white_d30 = "#B2B2B2"
local white_d15 = "#E0E0E0"
local red = "#FF0000"
local red_d50 = "#800000"
local red_l10 = "#FF3333"
local red_l20 = "#FF6666"

-- Core UI
hl("Normal", { fg = white, bg = black })
hl("NormalNC", { fg = white, bg = black })
hl("CursorLine", { bg = black_l5 })
hl("CursorColumn", { bg = black_l5 })

-- Cursor
hl("Cursor", { fg = black, bg = red })
hl("lCursor", { fg = black, bg = red })
hl("CursorIM", { fg = black, bg = red })

-- Text
hl("Comment", { fg = white_d40, italic = true })
hl("String", { fg = red })
hl("Number", { fg = red })
hl("Boolean", { fg = red })
hl("Identifier", { fg = white })
hl("Function", { fg = red, bold = true })

-- Syntax
hl("Keyword", { fg = red, bold = true })
hl("Statement", { fg = white })
hl("Operator", { fg = white_d15 })

-- Punctuation
hl("Delimiter", { fg = white })
hl("Punctuation", { fg = white })
hl("Special", { fg = white })
hl("SpecialChar", { fg = white })
hl("NonText", { fg = white_d50 })

-- Treesitter: punctuation is dim white, not red — reduces noise
hl("@punctuation.delimiter", { fg = white_d15 })
hl("@punctuation.bracket",   { fg = white_d15 })
hl("@punctuation.special",   { fg = white_d15 })

-- Treesitter: syntax categories
hl("@variable",              { fg = white })
hl("@variable.parameter",    { fg = white_d15 })
hl("@variable.builtin",      { fg = red_l10 })
hl("@constant",              { fg = red })
hl("@constant.builtin",      { fg = red, bold = true })
hl("@string",                { fg = red })
hl("@number",                { fg = red })
hl("@boolean",               { fg = red, bold = true })
hl("@type",                  { fg = white, bold = true })
hl("@type.builtin",          { fg = white_d15, bold = true })
hl("@keyword",               { fg = red, bold = true })
hl("@keyword.return",        { fg = red, bold = true })
hl("@keyword.operator",      { fg = red })
hl("@function",              { fg = red, bold = true })
hl("@function.builtin",      { fg = red_l10, bold = true })
hl("@function.call",         { fg = white })
hl("@method",                { fg = red, bold = true })
hl("@method.call",           { fg = white })
hl("@property",              { fg = white_d15 })
hl("@field",                 { fg = white_d15 })
hl("@namespace",             { fg = white_d15 })
hl("@operator",              { fg = white_d15 })

-- Markdown frontmatter — uniformly grey (see after/queries/markdown/highlights.scm)
hl("@markdownFrontmatter", { fg = white_d40 })

-- HTML treesitter groups (explicit, don't rely on fallback chain)
hl("@tag",                   { fg = white })
hl("@tag.builtin",           { fg = white })
hl("@tag.attribute",         { fg = white_d15 })
hl("@tag.delimiter",         { fg = white_d15 })

-- Legacy HTML syntax groups (fallback when treesitter isn't active)
-- htmlTag/htmlEndTag would otherwise inherit Function → red
hl("htmlTag",                { fg = white_d15 })
hl("htmlEndTag",             { fg = white_d15 })
hl("htmlTagName",            { fg = white })
hl("htmlSpecialTagName",     { fg = white })
hl("htmlArg",                { fg = white_d15 })
hl("htmlString",             { fg = red })

-- UI elements
hl("LineNr", { fg = white_d50, bg = black })
hl("CursorLineNr", { fg = white, bold = true })
hl("StatusLine", { fg = white, bg = black_l10 })
hl("StatusLineNC", { fg = white_d40, bg = black })

-- Visual / search
hl("Visual", { bg = red_d50 })
hl("Search", { fg = black, bg = red })
hl("IncSearch", { fg = black, bg = red_l10 })

-- Diagnostics (simple)
hl("DiagnosticError", { fg = red })
hl("DiagnosticWarn", { fg = red_l20 })
hl("DiagnosticInfo", { fg = white })
hl("DiagnosticHint", { fg = white_d30 })

vim.api.nvim_set_hl(0, 'MinuetVirtualText', { fg = '#808080', italic = true })
