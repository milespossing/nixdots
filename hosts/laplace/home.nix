{
  config,
  pkgs,
  outputs,
  inputs,
  ...
}:
{
  imports = [
    ../../home
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mpossing";
  home.homeDirectory = "/home/mpossing";

  mp.user-space.enable = true;
  # hyprland.enable = true;
  sdev.racket = {
    enable = true;
    full = true;
  };

  home.packages = with pkgs; [
    calibre
    librecad
  ];

  services.protonmail-bridge.enable = true;

  sdev.all = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
