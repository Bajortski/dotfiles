# config.nu — nushell interactive configuration.
# Tracked in ~/dotfiles/.config/nushell/, symlinked into
# ~/Library/Application Support/nushell/ (nushell's config dir on macOS).

$env.config.show_banner = false

# --- prompt ------------------------------------------------------------------
# fish rendered "toast ~/d/dotfiles > " using prompt_pwd, which shortens every
# component but the last to its first character (keeping the dot on dotdirs).
# Rebuilt here by hand, since nushell has no equivalent builtin.
def prompt-pwd []: nothing -> string {
    let path = ($env.PWD | str replace $nu.home-dir "~")
    let parts = ($path | split row "/")
    let last = (($parts | length) - 1)
    if $last < 1 { return $path }

    $parts
    | enumerate
    | each {|it|
        if $it.index == $last {
            $it.item
        } else if ($it.item | str starts-with ".") {
            $it.item | str substring ..<2
        } else {
            $it.item | str substring ..<1
        }
    }
    | str join "/"
}

$env.PROMPT_COMMAND = {|| $"($env.USER) (ansi green)(prompt-pwd)(ansi reset)" }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = " > "
$env.PROMPT_INDICATOR_VI_INSERT = " > "
$env.PROMPT_INDICATOR_VI_NORMAL = " < "
$env.PROMPT_MULTILINE_INDICATOR = " :: "

# --- zoxide ------------------------------------------------------------------
# env.nu regenerates this file on every launch.
source ~/.cache/zoxide.nu

# --- secrets -----------------------------------------------------------------
# Not tracked in this repo. See ~/secrets.nu.
source ~/secrets.nu

# --- greeting ----------------------------------------------------------------
source ~/dotfiles/.config/nushell/greeting.nu
greeting
