{ pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 5;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 4;
          blur_size = 10;
          noise = 0.02;
          contrast = 0.9;
          brightness = 0.6;
          vibrancy = 0.2;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.26;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgba(203, 166, 247, 1)";
          inner_color = "rgba(30, 30, 46, 0.8)";
          font_color = "rgba(205, 214, 244, 1)";
          fade_on_empty = true;
          placeholder_text = "<i>  Password...</i>";
          hide_input = false;
          position = "0, -60";
          halign = "center";
          valign = "center";
          check_color = "rgba(137, 180, 250, 1)";
          fail_color = "rgba(243, 139, 168, 1)";
          fail_text = "<i>$FAIL</i>";
          capslock_color = "rgba(250, 179, 135, 1)";
        }
      ];

      label = [
        {
          text = ''cmd[update:1000] echo "$(date +"%I:%M %p")"'';
          color = "rgba(205, 214, 244, 1)";
          font_size = 72;
          font_family = "DepartureMono Nerd Font";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(186, 194, 222, 0.8)";
          font_size = 20;
          font_family = "DepartureMono Nerd Font";
          position = "0, 130";
          halign = "center";
          valign = "center";
        }
        {
          text = "$USER";
          color = "rgba(203, 166, 247, 1)";
          font_size = 18;
          font_family = "DepartureMono Nerd Font";
          position = "0, 10";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:3600] ${pkgs.writeShellScript "hyprlock-uptime" ''
            uptime -p | sed 's/up /󰔟  /'
          ''}";
          color = "rgba(166, 227, 161, 0.7)";
          font_size = 12;
          font_family = "DepartureMono Nerd Font";
          position = "20, -20";
          halign = "left";
          valign = "top";
        }
      ];
    };
  };
}
