{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    pkgs.fastfetch
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
    pkgs.nushell
  ];
  ids.gids.nixbld = 350;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  system.stateVersion = 4;
  users.users.toast = {
    name = "toast";
    home = "/Users/toast";
  };
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  # Prebuilt neovim nightly, so the switch doesn't compile it from source.
  nix.settings.extra-substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # Keep the store tidy automatically. Weekly GC of generations older than
  # 30 days, then dedup the store. Package updates stay manual.
  nix.gc = {
    automatic = true;
    interval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    interval = [{ Weekday = 0; Hour = 4; Minute = 0; }];
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
