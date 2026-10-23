$env.config.show_banner = false

# Syntax highlighting in shades of red, grouped by role
let red_shades = {
    "#ff0000": [internalcall external_resolved keyword]
    "#ff4d4d": [external custom]
    "#cc0000": [flag operator pipe redirection]
    "#ff8080": [string externalarg filepath directory globpattern raw_string string_interpolation glob_interpolation]
    "#ffb3b3": [int float bool datetime range nothing literal binary]
    "#b30000": [variable vardecl signature match_pattern]
    "#e05050": [block closure list record table matching_brackets]
}
$env.config.color_config = (
    $red_shades | items {|hex, shapes| $shapes | each {|s| {$"shape_($s)": {fg: $hex}} } }
    | flatten | reduce --fold $env.config.color_config {|it, acc| $acc | merge $it }
)

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

$env.PROMPT_COMMAND = {|| $"(ansi { fg: "#ff0000" })($env.USER) (prompt-pwd)(ansi reset)" }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = $"(ansi { fg: "#ff0000" }) > (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi { fg: "#ff0000" }) > (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi { fg: "#ff0000" }) < (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = " :: "

source ~/.cache/zoxide.nu

source ~/secrets.nu

source ~/dotfiles/.config/nushell/greeting.nu
greeting
