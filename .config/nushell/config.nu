$env.config.show_banner = false

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

source ~/.cache/zoxide.nu

source ~/secrets.nu

source ~/dotfiles/.config/nushell/greeting.nu
greeting
