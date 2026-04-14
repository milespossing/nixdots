{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [ ", preferred, auto, 1" ];

    # Override nvidia env vars from shared config — laplace uses AMD
    env = lib.mkForce [
      "XDG_SESSION_TYPE,wayland"
      "NIXOS_OZONE_WL,1"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
    ];

    cursor = {
      no_hardware_cursors = lib.mkForce false;
    };
  };
}
