{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/media"
          "cpu"
          "memory"
          "temperature"
          "pulseaudio"
          "network"
          "bluetooth"
          "tray"
        ];

        "sway/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
          disable-scroll = false;
          all-outputs = false;
        };

        "sway/mode" = {
          format = "  {}";
          tooltip = false;
        };

        "sway/window" = {
          max-length = 40;
        };

        clock = {
          format = "{:%a %b %d  %I:%M %p}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "  {usage}%";
          interval = 5;
          tooltip-format = "{avg_frequency} GHz";
        };

        memory = {
          format = "  {percentage}%";
          interval = 5;
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        };

        temperature = {
          format = "{icon} {temperatureC}°C";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          critical-threshold = 80;
          tooltip = true;
        };

        "custom/media" = {
          format = "{}";
          interval = 5;
          exec = "${pkgs.writeShellScript "waybar-media" ''
            player_status=$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null)
            if [ "$player_status" = "Playing" ]; then
              artist=$(${pkgs.playerctl}/bin/playerctl metadata artist 2>/dev/null)
              title=$(${pkgs.playerctl}/bin/playerctl metadata title 2>/dev/null)
              echo "󰎆  $artist - $title" | cut -c1-40
            elif [ "$player_status" = "Paused" ]; then
              echo "󰏤"
            else
              echo ""
            fi
          ''}";
          on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = "󰤨  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰤭  disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-connected = "󰂯 {device_alias}";
          format-disabled = "󰂲";
          on-click = "blueman-manager";
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        font-family: "DepartureMono Nerd Font", sans-serif;
        font-size: 14px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.75);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
        background: transparent;
        border-bottom: 2px solid transparent;
        transition: all 0.3s ease;
      }

      #workspaces button.focused {
        color: #cba6f7;
        border-bottom: 2px solid #cba6f7;
      }

      #workspaces button:hover {
        background: rgba(49, 50, 68, 0.6);
        color: #f5e0dc;
      }

      #mode {
        color: #f38ba8;
        font-weight: bold;
        padding: 0 12px;
      }

      #window {
        color: #a6adc8;
        padding: 0 12px;
        font-style: italic;
      }

      #clock,
      #cpu,
      #memory,
      #temperature,
      #pulseaudio,
      #network,
      #bluetooth,
      #custom-media,
      #tray {
        padding: 0 12px;
      }

      #clock {
        color: #89b4fa;
      }

      #cpu {
        color: #f5c2e7;
      }

      #memory {
        color: #cba6f7;
      }

      #temperature {
        color: #94e2d5;
      }

      #temperature.critical {
        color: #f38ba8;
      }

      #custom-media {
        color: #a6e3a1;
      }

      #pulseaudio {
        color: #fab387;
      }

      #network {
        color: #a6e3a1;
      }

      #bluetooth {
        color: #89dceb;
      }

      tooltip {
        background-color: #1e1e2e;
        border: 1px solid #585b70;
        border-radius: 8px;
      }
    '';
  };
}
