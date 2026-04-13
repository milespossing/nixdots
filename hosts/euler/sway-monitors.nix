{ ... }:
{
  wayland.windowManager.sway.config = {
    output = {
      "DP-2" = {
        mode = "2560x1440@59.95Hz";
        position = "0 0";
      };
      "DP-1" = {
        mode = "2560x1440@143.97Hz";
        position = "2560 -8";
        transform = "270";
      };
    };

    workspaceOutputAssign = [
      {
        workspace = "1";
        output = "DP-2";
      }
      {
        workspace = "2";
        output = "DP-1";
      }
    ];
  };
}
