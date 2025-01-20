{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hyprland;
in
{
  options.hyprland.enable = lib.mkEnableOption "Enable hyprland dots";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slurp
      swayosd
      swww
      wl-clipboard
      wlogout
    ];

    home.file.".config/hypr" = {
      source = ../../dots/hyprland;
      recursive = true;
    };

    programs.eww = {
      enable = true;
    };

    home.file.".config/eww" = {
      source = ../../dots/eww;
      recursive = true;
    };
  };
}
