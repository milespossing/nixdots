{
  lib,
  pkgs,
  ...
}:
with lib;
{
  home.file.".local/share/rofi/themes" = {
    source = ./dots/themes;
    recursive = true;
  };


  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ".local/share/rofi/themes/catppuccin-mocha";
    extraConfig = {
      modes = "window,drun,run,ssh,combi";
      combi-modes = "run,window";
      combi-hide-mode-prefix = false;
    };
    plugins = with pkgs; [
      rofimoji
      rofi-rbw-wayland
      rofi-calc
    ];
  };
}
