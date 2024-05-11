{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.hyprland;
in {
  options.mp.hyprland.enable = lib.mkEnableOption "Enable hyprland dots";

  config = mkIf cfg.enable {
    home.programs = with pkgs; [
      slurp
      swayosd
      swww
      wl-clipboard
      wlogout
    ];
    home.file.".config/hypr" = {
      source = ../dots/hyprland;
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
  };
}
