vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.g.colors_name = "blackred"
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
hl("Statement", { fg = red })
hl("Operator", { fg = red })

-- Punctuation
hl("Delimiter", { fg = white }) -- covers many punctuation cases
hl("Punctuation", { fg = white })
hl("Special", { fg = white })
hl("SpecialChar", { fg = white })
hl("NonText", { fg = white_d50 })

-- Treesitter
hl("TSDelimiter", { fg = red })
hl("TSPunctDelimiter", { fg = red })
hl("TSPunctBracket", { fg = red })
hl("TSPunctSpecial", { fg = red })

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
