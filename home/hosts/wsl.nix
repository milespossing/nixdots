{ pkgs, ... }:
{
  imports = [
    ../../home
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "miles";
  home.homeDirectory = "/home/miles";

  nvim.enable = true;

  pathDirs = [ "$HOME/bin" ];

  programs.git = {
    userEmail = "milespossing@microsoft.com";
    extraConfig.credential.helper = "git-credential-manager.exe";
  };
  sdev.all = true;
  sdev.racket.full = true;

  shell.initExtra = ''
    export WSL=1
  '';

  home.packages = with pkgs; [
    multimarkdown
    mermaid-cli
    fontconfig
    wslu
    wsl-open
    xdg-utils
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  programs.home-manager.enable = true;
}
