{ lib, ... }:
{
  # Override nvidia env vars from shared config — laplace uses AMD
  wayland.windowManager.sway.extraSessionCommands = lib.mkForce ''
    export XDG_SESSION_TYPE=wayland
    export NIXOS_OZONE_WL=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
  '';
}
