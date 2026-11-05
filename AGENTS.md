# Installing these dotfiles on a fresh Mac (agent instructions)

You are setting up Bajortski's machine from this repo. Bajortski's pronouns are
it/its. Use the handle "Bajortski" anywhere a name is needed. Work through the
steps in order and run the checks in "Verify" before you report success.

## Ground rules

- **Do not read** `~/secrets.nu`, `~/secrets.fish` or `~/secrets.sh`. If one is
  missing, create it **empty** (step 5) and tell Bajortski to fill it in.
- **Do not push** this repo. Committing is fine; pushing needs an ask.
- **Before deleting or overwriting anything, look at it first.** On a fresh system
  most targets won't exist yet. If one does and isn't already the right symlink,
  move it to `<name>.bak` instead of deleting it.
- Use absolute symlink targets (`~/dotfiles/...`), not relative ones.
- Your own shell is probably zsh/bash. Anything you tell Bajortski to run by hand
  should use **nushell** syntax once nushell is installed.
- Some steps need Bajortski itself (GUI, passwords, keychain). Stop and ask at those
  points. Don't work around them.

## Assumptions baked into the config

Check these first. If any of them is false, ask Bajortski before changing the nix files.

| Thing | Value | Where |
|---|---|---|
| Arch | `aarch64-darwin` (Apple Silicon) | `flake.nix` |
| Hostname | `Funbox-Air-M3` | `flake.nix` (`darwinConfigurations."Funbox-Air-M3"`) |
| macOS user | `toast`, home `/Users/toast` | `flake.nix`, `system.nix` |
| Repo path | `~/dotfiles` | hardcoded in nushell config and the symlinks |
| `nixbld` group GID | `350` | `system.nix` (`ids.gids.nixbld`) |

- **Hostname:** if the new machine has a different name, either set it
  (`sudo scutil --set LocalHostName Funbox-Air-M3`, plus `HostName`/`ComputerName`)
  or pass `--flake ~/dotfiles#Funbox-Air-M3` explicitly. Ask which one Bajortski wants.
- **nixbld GID:** newer Nix installers create `nixbld` with GID 30000, not 350.
  After installing Nix, run `dscl . -read /Groups/nixbld PrimaryGroupID`. If it
  isn't 350, change `ids.gids.nixbld` in `system.nix` to match. Otherwise
  nix-darwin refuses to activate. Commit that change.

## 1. Prerequisites (manual / GUI)

1. Xcode Command Line Tools: `xcode-select --install`. Also install full Xcode if
   Bajortski wants to work on the Neovide icon (`icons/Neovide/README.md`).
2. Clone the repo to `~/dotfiles` if it isn't already there.
3. **Code-signing certificate.** `home.nix` re-signs Neovide with a self-signed
   identity called **"Bajortski Code Signing"** in the login keychain. If that
   identity is missing, the home-manager activation fails. Check it with:
   ```sh
   security find-identity -v -p codesigning | grep "Bajortski Code Signing"
   ```
   If it's missing, ask Bajortski to restore it from a backup (preferred, because
   it keeps existing Full Disk Access grants valid) or to make a new one in Keychain
   Access: Certificate Assistant > Create a Certificate, type "Code Signing",
   self-signed root. Don't generate one yourself without asking.

## 2. Nix

Install Nix with the **upstream** installer (multi-user):

```sh
sh <(curl -L https://nixos.org/nix/install)
```

Don't use the Determinate Systems installer. `system.nix` manages Nix itself
(`nix.settings`, `nix.gc`, `nix.optimise`), and nix-darwin needs `nix.enable = false`
under Determinate, which disables all of those options.

Open a new shell afterwards, then do the `nixbld` GID check above.

## 3. Homebrew + things nix doesn't manage

Some of the setup still lives outside nix:

- **Homebrew** at `/opt/homebrew`. `zsh/.zshrc` runs `brew shellenv`.
- **Rex** (Rex Beta, from superlogical). It isn't in nixpkgs. The nixpkgs package
  named `rex` is an unrelated Perl tool, so don't add it.
- **subtui**: install it if Bajortski wants it. Its config is linked in step 5
  either way.

zoxide, Ghostty and Halloy come from nix (step 4), so don't install them with
Homebrew. nushell's `env.nu` runs `zoxide init` on every start, so nushell errors
until the first switch is done.
- `.zshrc` also sources `~/.local/bin/env` (from the uv installer) and adds
  `~/.lmstudio/bin` to PATH. Install uv (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
  or zsh prints an error on every start.

Ask Bajortski before installing anything that isn't on this list.

## 4. First nix-darwin switch

nix-darwin isn't installed yet, so the first switch runs it from the flake:

```sh
sudo nix run nix-darwin -- switch --flake ~/dotfiles
```

- If it complains that `/etc/zshrc`, `/etc/bashrc` or similar files would be
  overwritten, rename each one to `<file>.before-nix-darwin`, as the error message
  says, and run it again.
- The first build is slow: Neovide nightly and its skia are built from source.
  neovim-nightly comes prebuilt from the nix-community cache.
- After that, rebuilds use the command below. `sudo` needs the absolute path:
  ```sh
  sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/dotfiles
  ```

This installs nushell, neovim nightly, fastfetch, fish, zoxide, Ghostty and Halloy
(the two apps go in `/Applications/Nix Apps`), git config (via
home-manager), Neovide (signed copy in `/Applications/Neovide.app` plus a `neovide`
wrapper), Touch ID for sudo, and weekly nix GC/optimise.

## 5. Symlinks

**Whole directories** are linked as directories. **Mixed directories** hold state
the app writes next to the config (history, logs, caches), so only the config files
inside them are linked, never the directory. Getting this wrong either clobbers the
app's state or puts that state into git.

| Link (create this) | Points to | Kind |
|---|---|---|
| `~/.config/nvim` | `~/dotfiles/.config/nvim` | dir |
| `~/.config/neovide` | `~/dotfiles/.config/neovide` | dir |
| `~/.config/rex` | `~/dotfiles/.config/rex` | dir |
| `~/Library/Application Support/nushell/config.nu` | `~/dotfiles/.config/nushell/config.nu` | file |
| `~/Library/Application Support/nushell/env.nu` | `~/dotfiles/.config/nushell/env.nu` | file |
| `~/Library/Application Support/nushell/greeting.nu` | `~/dotfiles/.config/nushell/greeting.nu` | file |
| `~/.config/fastfetch/config.jsonc` | `~/dotfiles/.config/fastfetch/config.jsonc` | file |
| `~/.config/subtui/config.toml` | `~/dotfiles/.config/subtui/config.toml` | file |
| `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/dotfiles/ghostty/Library/Application Support/com.mitchellh.ghostty/config` | file |
| `~/Library/Application Support/halloy/config.toml` | `~/dotfiles/halloy/config.toml` | file |
| `~/Library/Application Support/halloy/themes` | `~/dotfiles/halloy/themes` | dir |
| `~/.zshrc` | `~/dotfiles/zsh/.zshrc` | file |
| `~/.claude/skills/bajortski-design` | `~/dotfiles/claude/skills/bajortski-design` | dir |

Notes:

- On macOS, nushell reads its config from `~/Library/Application Support/nushell/`,
  not `~/.config/nushell/`. Link it there.
- Create the parent directories first (`mkdir -p`). Don't create the link's own path.
- For each row: if the link path already exists and is the correct symlink, skip
  it. If it exists as anything else, move it to `.bak` and tell Bajortski.
- `homepage/` and `icons/` aren't linked. The homepage is opened from the repo
  directly, and the icon is baked into the Neovide nix build.
- `.config/nvim/lazy-lock.json` is often dirty in git. That's normal, so leave it.

Then create the secrets files nushell and fish source at startup, **only if they
are missing**, and never open or print existing ones:

```sh
for f in ~/secrets.nu ~/secrets.fish ~/secrets.sh; do [ -e "$f" ] || : > "$f"; done
```

`config.nu` runs `source ~/secrets.nu` at parse time, so nushell won't start if the
file is missing.

## 6. Neovim plugins

```sh
nvim --headless "+Lazy! restore" +qa
```

This installs plugins at the versions pinned in `lazy-lock.json`. Run it after the
nvim symlink exists.

## 7. Verify

Run all of these and report the output. Don't claim success if something fails.

```sh
# nix-darwin active, right host
darwin-rebuild --list-generations | tail -1
scutil --get LocalHostName

# tools on PATH
which nu nvim neovide fastfetch zoxide git

# every link from the table resolves into ~/dotfiles
for l in ~/.config/nvim ~/.config/neovide ~/.config/rex \
  ~/Library/Application\ Support/nushell/{config,env,greeting}.nu \
  ~/.config/fastfetch/config.jsonc ~/.config/subtui/config.toml \
  ~/Library/Application\ Support/com.mitchellh.ghostty/config \
  ~/Library/Application\ Support/halloy/{config.toml,themes} \
  ~/.zshrc ~/.claude/skills/bajortski-design; do
  t=$(readlink "$l") && [ -e "$l" ] && echo "ok  $l" || echo "BAD $l -> $t"
done

# nushell starts cleanly (greeting prints, no errors)
nu -l -c 'version | get version'

# zsh starts cleanly
zsh -lic 'echo zsh ok'

# neovide is signed with the stable identity
codesign -dv /Applications/Neovide.app 2>&1 | grep -i authority

# neovim loads its config without errors
nvim --headless "+checkhealth lazy" +qa
```

## 8. Hand-off: things only Bajortski can do

Tell Bajortski which of these are still open:

- Fill in `~/secrets.nu` / `~/secrets.fish` / `~/secrets.sh`.
- Grant Full Disk Access to Neovide (System Settings > Privacy & Security) if it
  edits files in protected folders.
- Set Ghostty as the default terminal, and sign in to anything that needs accounts
  (Halloy servers, Navidrome/subtui, Rex).
- The login shell stays `/bin/zsh` on purpose. Ghostty launches `nu` itself, so
  don't `chsh`.

## Keeping this file current

If you add a config to the repo, add a row to the symlink table and the verify
loop in the same commit. If you change an assumption (hostname, user, GID,
installer), update the table at the top.
