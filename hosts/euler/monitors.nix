{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-2, 2560x1440@59.95, 0x0, 1"
      "DP-1, 2560x1440@143.97, 2560x-8, 1, transform, 1"
    ];

    workspace = [
      "1, monitor:DP-2, default:true"
      "2, monitor:DP-1, default:true"
    ];

    cursor = {
      default_monitor = "DP-2";
    };
  };
}
