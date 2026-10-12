{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.fastfetch
    pkgs.neovim
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
