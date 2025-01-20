{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mp.wm.gnome;
in
{
  options.mp.wm.gnome = {
    enable = mkEnableOption "Enables gnome";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      # misc.
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
