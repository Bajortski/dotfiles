{ pkgs, ... }: {
  home.stateVersion = "23.11";
  programs.git = {
    enable = true;
    settings = {
      user.name = "toast";
      user.email = "bajortskiproton.me@proton.me";
    };
};
  programs.zsh.enable = true;
}
