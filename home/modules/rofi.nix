{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.rofi;
in {
  options.mp.rofi.enable = lib.mkEnableOption "Enable rofi dots";

  config = mkIf cfg.enable {
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
  };
}
