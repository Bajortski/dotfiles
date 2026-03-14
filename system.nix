{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.fastfetch
  ];
  ids.gids.nixbld = 350;
  programs.zsh.enable = true;
  system.stateVersion = 4;
  users.users.toast = {
    name = "toast";
    home = "/Users/toast";
  };
}
