# env.nu — environment setup, evaluated before config.nu.
# Tracked in ~/dotfiles/.config/nushell/, symlinked into
# ~/Library/Application Support/nushell/ (nushell's config dir on macOS).

# --- nix-darwin system environment -------------------------------------------
# nix-darwin exports its environment from a generated sh script. fish picked
# that up through the fenv hook in /etc/fish/nixos-env-preinit.fish; nushell has
# no such hook, so pull the same script through bash and import the result.
# Going through /etc/static/bashrc rather than the store path keeps this correct
# across `darwin-rebuild switch`.
# This has to be a single probe: the import carries __NIX_DARWIN_SET_ENVIRONMENT_DONE
# across, so a second bash call would short-circuit and hand back bash's default
# PATH instead of the nix one.
let nix_env = (
    ^/bin/bash -c '. /etc/static/bashrc > /dev/null 2>&1; env -0'
    | split row (char nul)
    | where {|entry| $entry != "" }
    | parse -r '(?s)^(?<key>[^=]+)=(?<value>.*)$'
    | where key not-in ["_" "PWD" "OLDPWD" "SHLVL" "TERM"]
    | reduce -f {} {|it, acc| $acc | upsert $it.key $it.value }
)
load-env ($nix_env | reject --optional PATH)

# --- PATH --------------------------------------------------------------------
# Nushell keeps PATH as a list. Start from what nix-darwin hands out, keep
# whatever the parent process (Ghostty, launchd) already contributed, then
# prepend the user-level toolchains in the same priority order fish used.
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

# --- devkitPro ---------------------------------------------------------------
# Wii/GameCube homebrew toolchain, installed via dkp-pacman to /opt/devkitpro —
# not Homebrew and not nix. Needed by ~/git/hearth.
$env.DEVKITPRO = "/opt/devkitpro"
$env.DEVKITPPC = "/opt/devkitpro/devkitPPC"

# --- zoxide ------------------------------------------------------------------
# Regenerated on every launch so it can never go stale; config.nu sources it.
mkdir ($nu.home-dir | path join ".cache")
zoxide init nushell | save --force ($nu.home-dir | path join ".cache" "zoxide.nu")
