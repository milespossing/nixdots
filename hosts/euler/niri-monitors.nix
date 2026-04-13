{ ... }:
{
  programs.niri.settings.outputs = {
    "DP-2" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 59.95;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
    "DP-1" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 143.97;
      };
      position = {
        x = 2560;
        y = -8;
      };
      transform.rotation = 90;
    };
  };
}
