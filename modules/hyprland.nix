
{ config, lib, pkgs, inputs, ... }:
with lib;
let cfg = config.mp.wm.hyprland;
in {
  options.mp.wm.hyprland = {
    enable = mkEnableOption "Enables hyprland";
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    };

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      displayManager = {
        sddm.enable = true;
        sddm.wayland.enable = true;
        defaultSession = "hyprland";
      };
      # misc.
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
