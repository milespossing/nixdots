{ lib, ... }:
{
  # Override nvidia env vars from shared config — laplace uses AMD
  programs.niri.settings.environment = lib.mkForce {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    DISPLAY = ":0";
  };
}
