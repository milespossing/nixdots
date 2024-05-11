{ config, lib, ... }:
with lib;
let cfg = config.mp.user-space;
in {
  options.mp.user-space.enable = lib.mkEnableOption "Enable user-space dots, programs, and services";

  config = mkIf cfg.enable {
    mp.rofi.enable = true;
    imports = [
      ../alacritty-nord.nix
    ];

    home.packages = with pkgs; [
      firefox
      thunderbird
      protonmail-bridge
      discord
      element-desktop
      grim
      nwg-drawer
      racket
      spotify
      racket
      emacs29
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];

    fonts.fontconfig.enable = true;

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 13;
          normal.family = "FiraCode Nerd Font Mono";
        };
        window = {
          opacity = 0.9;
          blur = true;
        };
      };
    };

    home.file = {
      ".config/wallpapers" = {
        source = ./dots/wallpapers;
        recursive = true;
      };
    };
  };
}
