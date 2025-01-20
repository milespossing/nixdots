{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mp.user-space;
in
{
  options.mp.user-space.enable = lib.mkEnableOption "Enable user-space dots, programs, and services";

  config = mkIf cfg.enable {
    mp.rofi.enable = true;
    programs.emacs.enable = true;

    home.packages = with pkgs; [
      firefox
      chromium
      (vivaldi.overrideAttrs (oldAttrs: {
        dontWrapQtApps = false;
        dontPatchELF = true;
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
      }))
      thunderbird
      protonmail-bridge
      discord
      element-desktop
      grim
      nwg-drawer
      spotify
      vlc
      wl-clipboard
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 13;
          normal.family = "DepartureMono Nerd Font Mono";
        };
        window = {
          opacity = 0.9;
          blur = true;
        };
      };
    };

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        font_family = "DepartureMono Nerd Font";
      };
      themeFile = "Catppuccin-Macchiato";
      shellIntegration = {
        enableFishIntegration = true;
      };
    };

    home.file = {
      ".config/wallpapers" = {
        source = ../dots/wallpapers;
        recursive = true;
      };
    };

    programs.alacritty.settings.colors = {
      primary = {
        background = "#2e3440";
        foreground = "#d8dee9";
        dim_foreground = "#a5abb6";
      };
      cursor = {
        text = "#2e3440";
        cursor = "#d8dee9";
      };
      vi_mode_cursor = {
        text = "#2e3440";
        cursor = "#d8dee9";
      };
      selection = {
        text = "CellForeground";
        background = "#4c566a";
      };
      search = {
        matches = {
          foreground = "CellBackground";
          background = "#88c0d0";
        };
      };
      normal = {
        black = "#3b4252";
        red = "#bf616a";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        blue = "#81a1c1";
        magenta = "#b48ead";
        cyan = "#88c0d0";
        white = "#e5e9f0";
      };
      bright = {
        black = "#4c566a";
        red = "#bf616a";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        blue = "#81a1c1";
        magenta = "#b48ead";
        cyan = "#8fbcbb";
        white = "#eceff4";
      };
      dim = {
        black = "#373e4d";
        red = "#94545d";
        green = "#809575";
        yellow = "#b29e75";
        blue = "#68809a";
        magenta = "#8c738c";
        cyan = "#6d96a5";
        white = "#aeb3bb";
      };
    };
  };
}
