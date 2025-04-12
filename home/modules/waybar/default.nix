{
  config,
  lib,
  pkgs,
  ...
}:
{
  config.home.packages = with pkgs; [
    pavucontrol
    cava
    iniparser
    fftw
  ];

  options.waybar.custom.modules-left = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "hyprland/workspaces"
    ];
  };

  options.waybar.custom.modules-right = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "pulseaudio"
      "network"
      "cpu"
      "memory"
      "temperature"
      "tray"
      "clock"
    ];
  };
  config.programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin = "5 5";
        height = 30;
        spacing = 5;
        modules-left = config.waybar.custom.modules-left;
        modules-center = [
          "cava"
        ];
        modules-right = config.waybar.custom.modules-right;
        "hyprland/workspaces" = {
          all-outputs = true;
          # format-icons = true;
          format = "{icon} {windows}";
          format-window-separator = "";
          window-rewrite-default = " ";
          format-icons = {
            discord = " ";
            spotify = " ";
          };
          window-rewrite = {
            "class<zen.*>" = "󰖟 ";
            "class<zen.*> title<.*YouTube.*>" = " ";
            "class<kitty>" = " ";
            "class<kitty> title<nvim.*>" = " ";
            "class<thunderbird>" = " ";
            discord = "";
            Spotify = "";
          };
          sort-by = "id";
        };
        tray = {
          icon-size = 21;
          show-passive-icons = true;
          spacing = 10;
        };
        clock = {
          format = "{:%H:%M %Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "{usage}%  ";
          tooltip = false;
        };
        memory = {
          format = "{}%  ";
        };
        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          format-critical = "{temperatureC}°C {icon}";
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
        };
        cava = {
          # framerate = 30;
          # autosens = 1;
          # sensitivity = 100;
          bars = 32;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          hide_on_silence = true;
          # method = "pulse";
          # source = "auto";
          stereo = true;
          # reverse = false;
          bar_delimiter = 0;
          monstercat = true;
          waves = true;
          # noise_reduction = 0.77;
          # input_delay = 2;
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          actions = {
            on-click-right = "mode";
          };
        };
        backlight = {
          format = "{percent}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
        };
        "battery#bat2" = {
          bat = "BAT2";
        };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
        network = {
          format-wifi = " ";
          format-ethernet = "  ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          format-linked = "󰩠 ";
          format-disconnected = " ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          # format-source = "{volume}% ";
          # format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pgrep pavucontrol && pkill pavucontrol || pavucontrol &";
        };
        "custom/media" = {
          format = "{icon} {text}";
          return-type = "json";
          max-length = 40;
          format-icons = {
            spotify = "";
            default = "🎜";
          };
          escape = true;
          exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null";
        };
        "custom/power" = {
          format = "⏻ ";
          tooltip = false;
          menu = "on-click";
          menu-file = "$HOME/.config/waybar/power_menu.xml";
          menu-actions = {
            shutdown = "shutdown";
            reboot = "reboot";
            suspend = "systemctl suspend";
            hibernate = "systemctl hibernate";
          };
        };
      };
    };
    style = ./style.css;
  };
}
