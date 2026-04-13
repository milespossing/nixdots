{ ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 350;
        height = 150;
        offset = "10x10";
        origin = "top-right";
        transparency = 10;
        frame_color = "#cba6f7";
        frame_width = 2;
        corner_radius = 10;
        font = "DepartureMono Nerd Font 11";
        padding = 12;
        horizontal_padding = 12;
        icon_position = "left";
        max_icon_size = 48;
        background = "#1e1e2e";
        foreground = "#cdd6f4";
      };

      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#585b70";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#cba6f7";
        timeout = 10;
      };

      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        timeout = 0;
      };
    };
  };
}
