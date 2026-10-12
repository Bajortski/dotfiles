{ pkgs, lib, ... }:
let
  neovide = pkgs.callPackage ./pkgs/neovide { };
in {
  home.stateVersion = "23.11";
  programs.git = {
    enable = true;
    settings = {
      user.name = "toast";
      user.email = "bajortski@proton.me";
    };
};

  # Neovide is installed as a signed copy in /Applications rather than through
  # the nix app links. Nix builds are ad-hoc signed, so every rebuild changed the
  # cdhash and macOS forgot its Full Disk Access grant. Signing with a stable
  # self-signed identity (login keychain) keeps the designated requirement fixed.
  home.packages = [
    (pkgs.writeShellScriptBin "neovide" ''
      exec /Applications/Neovide.app/Contents/MacOS/neovide "$@"
    '')
  ];
  home.activation.neovideApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src=${neovide}/Applications/Neovide.app
    dst=/Applications/Neovide.app
    stamp="$HOME/.local/state/neovide-signed"
    if [ "$(cat "$stamp" 2>/dev/null)" != "$src" ] \
      || ! /usr/bin/codesign --verify --strict "$dst" 2>/dev/null; then
      run rm -rf "$dst"
      run cp -RL "$src" "$dst"
      run chmod -R u+w "$dst"
      run /usr/bin/codesign --force --deep -i com.neovide.neovide \
        --keychain "$HOME/Library/Keychains/login.keychain-db" \
        -s "Bajortski Code Signing" "$dst"
      if [[ ! -v DRY_RUN ]]; then
        mkdir -p "$(dirname "$stamp")" && echo "$src" > "$stamp"
      fi
    fi
  '';
}
