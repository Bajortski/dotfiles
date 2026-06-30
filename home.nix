{ pkgs, ... }: {
  home.stateVersion = "23.11";
  programs.git = {
    enable = true;
    settings = {
      user.name = "toast";
      user.email = "bajortski@proton.me";
    };
};
  programs.zsh.enable = true;
}
