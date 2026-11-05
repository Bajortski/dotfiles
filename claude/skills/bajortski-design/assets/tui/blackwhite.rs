//! blackwhite: Bajortski's nvim colorscheme for ratatui.
//! Source of truth: ~/.config/nvim/colors/blackwhite.lua
use ratatui::style::{Color, Modifier, Style};

pub const BG: Color = Color::Rgb(0x00, 0x00, 0x00);
pub const BG_L5: Color = Color::Rgb(0x0D, 0x0D, 0x0D);
pub const BG_L10: Color = Color::Rgb(0x1A, 0x1A, 0x1A);
pub const FG: Color = Color::Rgb(0xFF, 0xFF, 0xFF);
pub const FG_D15: Color = Color::Rgb(0xE0, 0xE0, 0xE0);
pub const FG_D30: Color = Color::Rgb(0xB2, 0xB2, 0xB2);
pub const FG_D40: Color = Color::Rgb(0x9A, 0x9A, 0x9A);
pub const FG_D50: Color = Color::Rgb(0x80, 0x80, 0x80);
pub const RED: Color = Color::Rgb(0xFF, 0x00, 0x00);
pub const RED_L10: Color = Color::Rgb(0xFF, 0x33, 0x33);
pub const RED_L20: Color = Color::Rgb(0xFF, 0x66, 0x66);
pub const RED_D50: Color = Color::Rgb(0x80, 0x00, 0x00);

pub fn base() -> Style { Style::new().fg(FG).bg(BG) }
pub fn muted() -> Style { Style::new().fg(FG_D40).add_modifier(Modifier::ITALIC) }
pub fn gutter() -> Style { Style::new().fg(FG_D50) }
pub fn cursor_row() -> Style { Style::new().bg(BG_L5) }
pub fn selected_row() -> Style { Style::new().bg(RED_D50) }
pub fn key() -> Style { Style::new().fg(RED).add_modifier(Modifier::BOLD) }
pub fn search_match() -> Style { Style::new().fg(BG).bg(RED) }
pub fn current_match() -> Style { Style::new().fg(BG).bg(RED_L10) }
pub fn error() -> Style { Style::new().fg(RED) }
pub fn warning() -> Style { Style::new().fg(RED_L20) }
pub fn statusline() -> Style { Style::new().fg(FG).bg(BG_L10) }
pub fn statusline_mode() -> Style { Style::new().fg(BG).bg(FG).add_modifier(Modifier::BOLD) }
pub fn border(focused: bool) -> Style { Style::new().fg(if focused { FG } else { FG_D50 }) }
