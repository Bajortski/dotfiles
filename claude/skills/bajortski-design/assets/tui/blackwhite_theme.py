"""blackwhite: Bajortski's nvim colorscheme as a Textual theme.

Source of truth: ~/.config/nvim/colors/blackwhite.lua

    from blackwhite_theme import BLACKWHITE
    class MyApp(App):
        CSS_PATH = "blackwhite.tcss"
        def on_mount(self):
            self.register_theme(BLACKWHITE)
            self.theme = "blackwhite"
"""
from textual.theme import Theme

BG, BG_L5, BG_L10 = "#000000", "#0D0D0D", "#1A1A1A"
FG, FG_D15, FG_D30, FG_D40, FG_D50 = "#FFFFFF", "#E0E0E0", "#B2B2B2", "#9A9A9A", "#808080"
RED, RED_L10, RED_L20, RED_D50 = "#FF0000", "#FF3333", "#FF6666", "#800000"

BLACKWHITE = Theme(
    name="blackwhite",
    primary=FG,
    secondary=FG_D40,
    accent=RED,
    warning=RED_L20,
    error=RED,
    success=FG,
    foreground=FG,
    background=BG,
    surface=BG,
    panel=BG_L10,
    dark=True,
    variables={
        # list/table cursor = CursorLine, not a coloured block
        "block-cursor-background": BG_L10,
        "block-cursor-foreground": FG,
        "block-cursor-text-style": "bold",
        "block-cursor-blurred-background": BG_L5,
        "block-cursor-blurred-foreground": FG_D15,
        "block-cursor-blurred-text-style": "none",
        "border": FG,
        "border-blurred": FG_D50,
        "input-cursor-background": RED,
        "input-cursor-foreground": BG,
        "input-selection-background": RED_D50,
        "footer-background": BG_L10,
        "footer-item-background": BG_L10,
        "footer-key-background": BG_L10,
        "footer-key-foreground": RED,
        "footer-description-background": BG_L10,
        "footer-description-foreground": FG_D15,
        "scrollbar": FG_D50,
        "scrollbar-hover": FG_D40,
        "scrollbar-active": FG,
        "scrollbar-background": BG,
        "scrollbar-background-hover": BG,
        "scrollbar-background-active": BG,
        "scrollbar-corner-color": BG,
        "surface-active": BG_L5,
    },
)
