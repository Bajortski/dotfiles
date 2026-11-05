# Web tools

Web tools should look like they belong next to bajortski.net: a stark, black-and-white,
monospace page built on a character grid. The site's stylesheet is lifted from
[The Monospace Web](https://owickstrom.github.io/the-monospace-web/); this skill carries a
trimmed copy plus a few tool-oriented extras.

## Quick start

1. Copy `assets/web/base.css` and `assets/web/template.html` into the new project
   (rename the template to `index.html`, replace `TOOL_NAME`).
2. Build the tool inside that page. Reach for the existing element styles first;
   add new CSS only for what genuinely isn't covered.
3. Before finishing, run through the checklist at the bottom.

If the site's stylesheet has changed since this skill was written, re-read
`~/git/bajortski.net/stylesheet.css` and prefer it — the site is the source of truth.

## The look

- **Font:** Maple Mono (Bajortski's favourite), from fontsource on jsdelivr, fallback
  `monospace`. Everything is monospace — inputs, buttons, code, headings.
- **Colour:** pure black on white, pure white on black in dark mode. One alt tone for
  muted text (`#666` / `#aaa`) and one for hover backgrounds (`#eee` / `#111`). No accent
  colour, no gradients, no shadows, no border-radius (radios aside). Emphasis comes from
  weight, inversion (`.selected`), borders and uppercase, not hue. If a tool truly needs
  colour (charts, diffs, swatches), confine it to the data, never the chrome.
- **Grid:** spacing is in `1ch` horizontally and `var(--line-height)` (1.2rem) vertically.
  Widths round down to whole `ch`. The global `* + * { margin-top: var(--line-height) }`
  gives vertical rhythm for free — don't fight it with ad-hoc margins; use multiples or
  halves of `--line-height`.
- **Page:** single column, `max-width: 80ch`, `2ch` side padding (`1ch` under 480px).
  Content is centred in the viewport by `<html>` flex.
- **Borders:** `2px` solid `var(--text-color)` (`--border-thickness`). Focus = thicker
  border (3px), no outline glow. `<hr>` is a double rule.
- **Type:** `h1` 1.75rem uppercase bold; `h2` 1rem uppercase. Body 16px/400. Links keep the
  text colour, underlined at border thickness. Secondary links and marquees use weight 200.
  Buttons are uppercase, weight 500, and nudge `2px, 2px` on `:active`.
- **Lowercase voice:** labels, link text, nav, and status text are lowercase
  ("links", "version", "blog"). Headings get uppercased by CSS — write them in normal case.

## Signature components

| Component | How | Notes |
| --- | --- | --- |
| Header table | `<table class="header">` with title cell (`.width-auto`), `version` th, version td (`.width-min`), and a full-width marquee row | Every page opens with this. Title can link home with `.no-underline`. |
| Marquee | `.marquee` / `.marquee-header` wrapping a `<p>` whose text is a unit repeated ~60–100× | Animates `translate(-50%)`; repeating makes the loop seamless. Good for status tickers, tips, recent events. Weight 200. |
| Bordered tables | plain `<table>`, `th`/`td` | Used for layout too (gallery uses colspan/rowspan grids). Wrap wide data tables in `.scroll-x`. |
| Tree | `<ul class="tree">` | ASCII-ish tree lines for file lists, hierarchies, indexes. |
| Duo list | `<ul class="duo-list">` | Two-column `key: value` list, collapses to one column on mobile. |
| Details | `<details><summary>` | Bordered box with ▶/▼ markers. Use for collapsible sections. |
| Grid | `<div class="grid">` with 1–9 children | Equal ch-snapped columns, e.g. a row of buttons/inputs. |
| Toolbar *(tool extra)* | `<div class="toolbar">` | Wrapping row of inputs/buttons without the stacked margins. |
| Status line *(tool extra)* | `<p class="status">` | Muted, top-bordered one-liner: counts, state, key hints. |
| Selected *(tool extra)* | `.selected` / `aria-pressed="true"` | Inverted colours, the site's swatch "pressed" look. |
| Panel *(tool extra)* | `.panel` | A `<details>`-style box that isn't collapsible. |

## Behaviour

- **Theme:** follow `prefers-color-scheme`; override via `data-theme="light|dark"` on
  `<html>`, persisted in `localStorage.theme`. Pressing **`t`** (not in an input, no
  modifiers) toggles; toggling back to the system value removes the override. The
  template already has this plus the anti-flash pre-paint script.
- **Keyboard first:** single-key shortcuts for common actions are on-brand. Show them with
  `<kbd>` in the status line.
- **Motion:** only marquees and small transform nudges. Respect
  `prefers-reduced-motion` (base.css stops marquees).
- **No frameworks by default.** Static HTML/CSS/vanilla JS, no build step, like the site.
  Pull in a library only when the tool genuinely needs it. Wrap every `localStorage`
  access in try/catch.

## Don'ts

- No card UIs, rounded corners, drop shadows, pill buttons, icon fonts, or emoji.
- No sans-serif anywhere, no second typeface.
- No accent-colour chrome (blue buttons, coloured headers).
- Don't hard-code pixel spacing off the ch/line grid; don't use `rem` widths.
- Don't copy the site's personal content (muppet header, links list, copyright marquee,
  colour picker) into tools unless asked.

## Checklist before handing over

- [ ] Loads Maple Mono; nothing renders in a non-mono font.
- [ ] Light and dark both work (system setting and `t` toggle), no white flash in dark.
- [ ] Opens with the header table; headings are uppercase via CSS.
- [ ] Spacing snaps to `ch` / `--line-height`; no stray px margins.
- [ ] Works at phone width (≤480px): no horizontal page scroll, tables in `.scroll-x`.
- [ ] Only black/white/alt-grey in chrome.
- [ ] JS passes the complexity lint rule from CLAUDE.md (table-driven dispatch over long
      if/switch chains).
- [ ] Verify visually by rendering headlessly (see the headless-browser memory: Helium
      over CDP), never by screencapturing the desktop.
