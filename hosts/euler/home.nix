{ config, pkgs, ... }:
{
  imports = [
    ../../home
    ../../home/modules/hyprland
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "miles";
  home.homeDirectory = "/home/miles";

  home.packages = with pkgs; [
    calibre
    tetrio-desktop
  ];

  mp.user-space.enable = true;
  sdev.racket.full = true;
  sdev.all = true;

  home.file.".config/wallpaper.png" = {
    source = ../../home/dots/wallpapers-mocha/hor/pixel1.png;
  };

  home.file.".config/wallpaper-vert.png" = {
    source = ../../home/dots/wallpapers-mocha/vert/city-pixels.png;
  };

  services.protonmail-bridge.enable = true;

  hyprland = {
    pre-source = ''
      monitor = DP-2, 2560x1440@60, 0x0, 1
      monitor = DP-1, 2560x1440@60, 2560x0, 1, transform, 1

      $mainMon = DP-2
      $sideMon = DP-1

      workspace = 1, monitor:$mainMon
      workspace = 2, monitor:$sideMon
    '';
    pre-config = ''
      exec-once=swww img -o DP-2 ~/.config/wallpaper.png
      exec-once=swww img -o DP-1 ~/.config/wallpaper-vert.png

      cursor {
        no_hardware_cursors = true
      }
    '';
  };

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
