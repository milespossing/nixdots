{ pkgs, lib, ... }:
{
  imports = [
    ./basic.nix
    ./user-space.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
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
    slurp
    swayosd
    swww
    wl-clipboard
    wlogout
  ];

  home.file = {
    ".config/wallpapers" = {
      source = ./dots/wallpapers;
      recursive = true;
    };
  };

  home.file.".config/emacs" = {
    source = ./dots/emacs;
    recursive = true;
  };

  programs.waybar = {
    enable = true;
  };

  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ./dots/eww;
  };

  home.file = {
    ".config/hypr" = {
      source = ./dots/hyprland;
      recursive = true;
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "Arc-Dark";
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

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29;
  };

  services.emacs = {
    enable = true;
  };

  systemd.user.services.protonmail-bridge = {
    Unit = {
      Description = "Proton Mail Bridge";
      After = [ "network.target" ];
    };
    Service = {
      Restart = "always";
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
