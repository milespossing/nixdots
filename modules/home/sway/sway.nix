{ pkgs, ... }:
let
  mod = "Mod4";
  terminal = "kitty";
  menu = "rofi -show drun -show-icons";

  color-picker = pkgs.writeShellScript "sway-color-picker" ''
    grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
    notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
  '';

  wallpaper-cycle = pkgs.writeShellScript "sway-wallpaper-cycle" ''
    img="$(find ~/Pictures/wallpapers -type f | shuf -n1)"
    ${pkgs.awww}/bin/awww img "$img" --transition-type grow --transition-pos cursor --transition-duration 2
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    config = {
      modifier = mod;
      terminal = terminal;
      menu = menu;

      fonts = {
        names = [ "DepartureMono Nerd Font" ];
        size = 11.0;
      };

      gaps = {
        inner = 5;
        outer = 10;
      };

      window = {
        border = 2;
        titlebar = false;
      };

      floating = {
        border = 2;
        titlebar = false;
      };

      colors = {
        focused = {
          border = "#cba6f7";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#89b4fa";
          childBorder = "#cba6f7";
        };
        focusedInactive = {
          border = "#585b70";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#585b70";
          childBorder = "#585b70";
        };
        unfocused = {
          border = "#585b70";
          background = "#1e1e2e";
          text = "#6c7086";
          indicator = "#585b70";
          childBorder = "#585b70";
        };
        urgent = {
          border = "#f38ba8";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f38ba8";
          childBorder = "#f38ba8";
        };
      };

      input = {
        "*" = {
          xkb_layout = "us";
        };
      };

      focus = {
        followMouse = true;
      };

      bars = [ ];

      startup = [
        { command = "waybar"; }
        { command = "nm-applet --indicator"; }
        { command = "wl-paste --type text --watch cliphist store"; }
        { command = "wl-paste --type image --watch cliphist store"; }
        { command = "/run/current-system/sw/lib/polkit-gnome/polkit-gnome-authentication-agent-1"; }
        {
          command = "${pkgs.awww}/bin/awww-daemon";
        }
        {
          command = "${pkgs.awww}/bin/awww img ~/Pictures/wallpaper.png --transition-type grow --transition-duration 2";
          always = false;
        }
      ];

      keybindings = {
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+q" = "kill";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
        "${mod}+e" = "exec ${terminal} -e yazi";
        "${mod}+v" = "floating toggle";
        "${mod}+d" = "exec ${menu}";
        "${mod}+f" = "fullscreen";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+t" = "layout toggle split";

        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up" = "focus up";
        "${mod}+Down" = "focus down";
        "${mod}+h" = "focus left";
        "${mod}+l" = "focus right";
        "${mod}+k" = "focus up";
        "${mod}+j" = "focus down";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+j" = "move down";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+r" = "mode resize";
        "${mod}+o" = "mode launch";

        "Print" = ''exec grim -g "$(slurp)" - | swappy -f -'';
        "${mod}+Print" = "exec grim - | swappy -f -";

        "${mod}+Shift+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
        "${mod}+Shift+c" = "exec ${color-picker}";
        "${mod}+Shift+w" = "exec ${wallpaper-cycle}";

        "XF86AudioMute" = "exec pamixer -t";
        "XF86AudioRaiseVolume" = "exec pamixer -i 5";
        "XF86AudioLowerVolume" = "exec pamixer -d 5";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
      };

      modes = {
        resize = {
          "h" = "resize shrink width 20px";
          "l" = "resize grow width 20px";
          "k" = "resize shrink height 20px";
          "j" = "resize grow height 20px";
          "Left" = "resize shrink width 20px";
          "Right" = "resize grow width 20px";
          "Up" = "resize shrink height 20px";
          "Down" = "resize grow height 20px";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
        launch = {
          "t" = "exec ${terminal}; mode default";
          "b" = "exec zen; mode default";
          "f" = "exec ${terminal} -e yazi; mode default";
          "d" = "exec discord; mode default";
          "s" = "exec spotify; mode default";
          "p" = "exec pavucontrol; mode default";
          "Escape" = "mode default";
        };
      };

      window.commands = [
        {
          command = "floating enable";
          criteria = {
            app_id = "pavucontrol";
          };
        }
        {
          command = "floating enable";
          criteria = {
            app_id = "nm-connection-editor";
          };
        }
        {
          command = "floating enable";
          criteria = {
            title = "^Picture-in-Picture$";
          };
        }
        {
          command = "sticky enable";
          criteria = {
            title = "^Picture-in-Picture$";
          };
        }
        {
          command = "move container to workspace number 2";
          criteria = {
            app_id = "firefox";
          };
        }
        {
          command = "move container to workspace number 2";
          criteria = {
            app_id = "zen";
          };
        }
        {
          command = "move container to workspace number 4";
          criteria = {
            class = "discord";
          };
        }
        {
          command = "move container to workspace number 5";
          criteria = {
            class = "Spotify";
          };
        }
        {
          command = "floating enable, resize set 60ppt 70ppt, move position center";
          criteria = {
            app_id = "^scratchterm$";
          };
        }
      ];
    };

    extraSessionCommands = ''
      export LIBVA_DRIVER_NAME=nvidia
      export XDG_SESSION_TYPE=wayland
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export NIXOS_OZONE_WL=1
      export ELECTRON_OZONE_PLATFORM_HINT=auto
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };
}
