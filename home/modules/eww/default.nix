{ inputs, lib, config, pkgs, ... }:
with lib;
let 
  cfg = config.mp.eww;
in {
  options.mp.eww = { enable = mkEnableOption "eww"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      eww-wayland
      # pamixer
      # brightnessctl
    ];

    home.file.".config/eww/eww.scss".source = ./eww.scss;
    home.file.".config/eww/eww.yuck".source = ./eww.yuck;
  };
}
