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
  imports = [
    ../rofi
    ../waybar
    ../eww.nix
  ];

  options.hyprland = {
    pre-source = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    post-source = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    pre-config = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = {
    home.file.".config/hypr/conf/pre-source.conf".text = cfg.pre-source;
    home.file.".config/hypr/conf/post-source.conf".text = cfg.post-source;
    home.file.".config/hypr/conf/pre-config.conf".text = cfg.pre-config;

    home.packages = with pkgs; [
      playerctl
    ];

    # TODO: Need to get the below active once stable

    home.file.".config/hypr" = {
      source = dots/hypr;
      recursive = true;
    };
  };
}
