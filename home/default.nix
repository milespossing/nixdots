{ pkgs, lib, ... }:
{
  imports = [
    ./basic.nix
    ./user-space.nix
    ./alacritty-nord.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
    ];

  home.packages = with pkgs; [
    protonmail-bridge
    slurp
    grim
    swww
    nwg-drawer
    swayosd
    wl-clipboard
    wlogout
  ];

  home.file = {
    ".config/wallpapers" = {
      source = ./dots/wallpapers;
      recursive = true;
    };
  };

  programs.waybar = {
    enable = true;
    ### TODO: Update this
    # settings = {
    #   position = "top";
    #   height = 5;
    # };
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
