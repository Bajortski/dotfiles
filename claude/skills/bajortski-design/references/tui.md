# TUIs

TUIs should feel like a pane of Bajortski's Neovim: its own `blackwhite` colorscheme
(`~/.config/nvim/colors/blackwhite.lua`), a flat lualine-style statusline, a
snacks.nvim-style start screen with keyed actions, and which-key-style hints.
Bajortski runs it in Neovide/Ghostty with Maple Mono NF, so Nerd Font glyphs render.

Existing TUIs to stay consistent with: `~/git/bsky-notify` (Textual),
`~/git/searchsearch` (ratatui). Default to Textual for Python, ratatui for Rust.

## Palette (`blackwhite`)

| Token | Hex | nvim use | TUI use |
| --- | --- | --- | --- |
| `bg` | `#000000` | Normal bg | screen background |
| `bg_l5` | `#0D0D0D` | CursorLine | highlighted/hovered row |
| `bg_l10` | `#1A1A1A` | StatusLine bg | statusline, header bar, panel fills |
| `fg` | `#FFFFFF` | Normal fg, identifiers | body text, focused borders |
| `fg_d15` | `#E0E0E0` | operators, properties, punctuation | secondary text, field values |
| `fg_d30` | `#B2B2B2` | hints | hint text |
| `fg_d40` | `#9A9A9A` | comments (italic), inactive statusline | muted/meta text, timestamps, unfocused borders |
| `fg_d50` | `#808080` | line numbers, NonText | gutters, separators, disabled |
| `red` | `#FF0000` | keywords, functions, strings, cursor, search | **the** accent: key letters, matches, errors, cursor |
| `red_l10` | `#FF3333` | IncSearch, builtins | active/current match |
| `red_l20` | `#FF6666` | warnings | warnings |
| `red_d50` | `#800000` | Visual selection | selected rows / multi-select |

Assumes dark. If a light variant is ever needed, invert the neutral ramp and keep the
reds.

## How to use red

Red is the only hue and it carries meaning: *this is actionable or this matched*. In nvim
it marks keywords, functions, strings and the cursor; translate that to:

- the key letter in a keybind hint or menu (`[f] search` with `f` in bold red),
- search/filter matches (black on red, like `Search`),
- the cursor/caret and focused-item marker,
- errors (plain red) and warnings (`red_l20`),
- selection background (`red_d50`) for chosen rows.

Never red for borders, titles, or large fills. If more than a sprinkle of the screen is
red, pull back.

## Layout pieces

- **Statusline (lualine).** One row at the bottom, `bg_l10` background, no powerline
  arrows (separators are blank in Bajortski's config). Left to right: mode in a bold
  block (`NORMAL`/`SEARCH`/etc. or the app's equivalent), context (branch/source/
  counts), name of the current thing; right side: meta (encoding-ish detail, type), then
  position (`12/340`) and a `? keys` hint. Global — one statusline for the whole app, not
  per pane. It replaces Textual's `Footer`; don't stack both.
- **Start screen (snacks dashboard).** Centred quote or short header at top, then a
  vertical keyed menu with a blank line between items: `icon  description  key`, all
  lowercase ("search", "browse recent files", "restore last session", "quit"). Key on the
  right, in red. Good for tools with several entry points.
- **Lists.** Current row on `bg_l5`, selected rows on `red_d50`. Optional relative or
  absolute line numbers in an `fg_d50` gutter (nvim uses relative numbers; use them when
  `j`/`k` counts make sense).
- **Panes and floats.** Single-line box borders (`┌─┐│└┘`). Focused pane border `fg`,
  unfocused `fg_d40`/`fg_d50`. Title inset in the top border, lowercase. Popups/pickers
  float centred over the main view like snacks picker / noice's command palette.
- **Key hints (which-key).** `?` or a leader key opens a compact panel of
  `key → action` pairs, grouped (`+search`, `+git`), keys in red, descriptions in `fg`.
- **Command line.** `:` opens a command prompt; `/` filters/searches. Show the prompt in
  the bottom row or as a small centred float (noice `command_palette` preset).
- **Messages.** Brief notices in the top-right (snacks notifier) or the statusline,
  dismissed automatically. No modal "OK" dialogs for information.
- **Empty space.** Hide the end-of-buffer `~` look (nvim has `eob = " "`); blank is fine.

## Interaction

- Vim motions: `j`/`k`/`g`/`G`/`ctrl-d`/`ctrl-u`, `h`/`l` between panes, `/` search,
  `n`/`N` next/prev match, `q` or `:q` quit, `esc` backs out. `[`/`]` for prev/next where
  it fits.
- Mouse works too (nvim has `mouse = "a"`), but nothing should require it.
- Bind keys through a table (key → action), not a long match/if-chain; keeps complexity
  lint happy and feeds the which-key panel from the same data.

## Don'ts

- No rainbow syntax, no second accent hue (no blue links, green success). Success is just
  white text.
- No powerline arrow separators, no gradients, no double-line or rounded heavy borders.
- No emoji. Nerd Font icons only in menus/status, not sprinkled through content.

## Checklist

- [ ] Background is pure black; only the palette above is used.
- [ ] Red appears only on keys, matches, cursor, errors/warnings, selection.
- [ ] Bottom statusline with mode / context / position.
- [ ] `?` shows keybinds; `q` quits; `/` searches; `j`/`k` move.
- [ ] Looks right at 80×24 and in a wide window.
- [ ] Snapshot rendered headlessly and checked.

## Starter assets

- **Textual:** `assets/tui/blackwhite_theme.py` (a `Theme`: palette plus cursor, input,
  footer and scrollbar colours — register it in `on_mount`) and
  `assets/tui/blackwhite.tcss` (panes, `#statusline`, `.selected`/`.key`/`.match`/
  `.muted`, and the overrides that stop Textual tinting focused lists grey). Tested on
  Textual 8.2.
- **ratatui:** `assets/tui/blackwhite.rs` — colour consts and `Style` helpers
  (`key()`, `search_match()`, `statusline_mode()`, `border(focused)` …). Checked against
  ratatui 0.29.
