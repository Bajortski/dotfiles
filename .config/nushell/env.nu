let nix_env = (
    ^/bin/bash -c '. /etc/static/bashrc > /dev/null 2>&1; env -0'
    | split row (char nul)
    | where {|entry| $entry != "" }
    | parse -r '(?s)^(?<key>[^=]+)=(?<value>.*)$'
    | where key not-in ["_" "PWD" "OLDPWD" "SHLVL" "TERM"]
    | reduce -f {} {|it, acc| $acc | upsert $it.key $it.value }
)
load-env ($nix_env | reject --optional PATH)

let nix_path = ($nix_env.PATH? | default "" | split row ":")

let current_path = ($env.PATH? | default [])
let inherited_path = if ($current_path | describe) == "string" {
    $current_path | split row ":"
} else {
    $current_path
}

$env.PATH = (
    []
    | append "/opt/devkitpro/tools/bin"          # devkitPro (see below)
    | append $"($nu.home-dir)/.cargo/bin"       # rustup, was conf.d/rustup.fish
    | append $"($nu.home-dir)/.local/bin"       # uv, was conf.d/uv.env.fish
    | append $nix_path
    | append $"/etc/profiles/per-user/($env.USER)/bin"  # home-manager packages
    | append "/opt/homebrew/bin"
    | append "/opt/homebrew/sbin"
    | append $inherited_path
    | where {|p| $p != "" }
    | uniq
)

$env.DEVKITPRO = "/opt/devkitpro"
$env.DEVKITPPC = "/opt/devkitpro/devkitPPC"

mkdir ($nu.home-dir | path join ".cache")
zoxide init nushell | save --force ($nu.home-dir | path join ".cache" "zoxide.nu")
