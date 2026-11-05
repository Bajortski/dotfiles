---
name: bajortski-design
description: Bajortski's house style for new projects with a UI. Web tools (browser UIs, local dashboards, HTML viewers, static pages) take after its site ~/git/bajortski.net; terminal UIs (Textual, ratatui, curses, any TUI) take after its Neovim setup. Use when starting or restyling any web tool or TUI for Bajortski, or when it says "like my site" / "like my nvim". Monochrome, monospace, keyboard-first. Not for native GUI apps.
---

# bajortski-design

Two surfaces, one sensibility. Pick the reference for the surface, read it fully,
then build.

| Building | Inspiration (source of truth) | Read | Starter assets |
| --- | --- | --- | --- |
| Web tool / page | `~/git/bajortski.net/` (`stylesheet.css`, `index.html`) | `references/web.md` | `assets/web/` |
| TUI | `~/.config/nvim/` (`colors/blackwhite.lua`, `lua/plugins/{lualine,snacks}.lua`) | `references/tui.md` | `assets/tui/` |

If the source of truth has changed since this skill was written, prefer it and say so.

## Shared principles

- **Monochrome first.** Black and white, plus greys for de-emphasis. Chrome never gets
  colour. The web side has no accent at all; the TUI side has exactly one (red), used
  sparingly — see its reference.
- **Monospace, grid-aligned.** Maple Mono everywhere a font can be chosen. Layout snaps
  to character cells: `ch` × line-height on the web, cells in the terminal.
- **Flat.** No shadows, gradients, glows, rounded cards, or decorative icons. Hierarchy
  comes from weight, inversion, borders and case.
- **Lowercase voice.** Labels, menu items, status text and keybind descriptions are
  lowercase ("browse recent files", "version", "links"). Big headings may be uppercased
  by styling.
- **Keyboard first.** Single-key actions, shown next to what they do. `q` quits, `?`
  shows keys, `t` toggles theme on the web.
- **No emoji.** Nerd Font glyphs are acceptable in TUIs (the nvim dashboard uses them as
  menu icons); never on the web.
- **Bits of personality are fine** — a quote on the start screen, a marquee — but tools
  don't copy the site's or nvim's personal content unless asked.

## Before handing over (both)

- [ ] Follows the surface's reference checklist.
- [ ] Complexity lint passes (CLAUDE.md rule; table-driven dispatch for keymaps/actions).
- [ ] Verified by offscreen render — headless browser screenshot for web, the
      framework's snapshot/headless mode for TUIs (Textual `run_test`/`save_screenshot`,
      ratatui `TestBackend`). Never screencapture the desktop.
