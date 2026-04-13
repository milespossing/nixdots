{ pkgs, ... }:
let
  color-picker = pkgs.writeShellScript "niri-color-picker" ''
    grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
    notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
  '';

  wallpaper-cycle = pkgs.writeShellScript "niri-wallpaper-cycle" ''
    img="$(find ~/Pictures/wallpapers -type f | shuf -n1)"
    ${pkgs.awww}/bin/awww img "$img" --transition-type grow --transition-pos cursor --transition-duration 2
  '';

  screenshot-region = pkgs.writeShellScript "niri-screenshot-region" ''
    grim -g "$(slurp)" - | swappy -f -
  '';
in
{
  programs.niri.settings = {
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot %Y-%m-%d %H-%M-%S.png";

    environment = {
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      DISPLAY = ":0";
    };

    input = {
      keyboard.xkb.layout = "us";
      focus-follows-mouse.enable = true;
      warp-mouse-to-focus.enable = true;
      workspace-auto-back-and-forth = true;
    };

    cursor = {
      size = 24;
      hide-when-typing = true;
      hide-after-inactive-ms = 5000;
    };

    layout = {
      gaps = 5;
      struts = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };

      center-focused-column = "on-overflow";

      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
        { proportion = 1.0; }
      ];

      default-column-width = {
        proportion = 1.0 / 2.0;
      };

      focus-ring = {
        enable = false;
      };

      border = {
        enable = true;
        width = 2;
        active.color = "#cba6f7";
        inactive.color = "#585b70";
        urgent.color = "#f38ba8";
      };

      shadow = {
        enable = true;
        softness = 12;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        draw-behind-window = false;
        color = "#1a1a2ecc";
        inactive-color = "#1a1a2e66";
      };
    };

    overview = {
      zoom = 0.5;
    };

    animations = {
      slowdown = 1.0;

      workspace-switch.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };

      window-open.kind.easing = {
        duration-ms = 200;
        curve = "ease-out-expo";
      };

      window-close.kind.easing = {
        duration-ms = 150;
        curve = "ease-out-quad";
      };

      horizontal-view-movement.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };

      window-movement.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };

      window-resize.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 800;
        epsilon = 0.0001;
      };

      config-notification-open-close.kind.spring = {
        damping-ratio = 0.6;
        stiffness = 1000;
        epsilon = 0.001;
      };
    };

    spawn-at-startup = [
      { command = [ "${pkgs.waybar}/bin/waybar" ]; }
      {
        command = [
          "nm-applet"
          "--indicator"
        ];
      }
      {
        command = [
          "${pkgs.wl-clipboard}/bin/wl-paste"
          "--type"
          "text"
          "--watch"
          "cliphist"
          "store"
        ];
      }
      {
        command = [
          "${pkgs.wl-clipboard}/bin/wl-paste"
          "--type"
          "image"
          "--watch"
          "cliphist"
          "store"
        ];
      }
      { command = [ "/run/current-system/sw/lib/polkit-gnome/polkit-gnome-authentication-agent-1" ]; }
      { command = [ "${pkgs.awww}/bin/awww-daemon" ]; }
      {
        command = [
          "${pkgs.awww}/bin/awww"
          "img"
          "~/Pictures/wallpaper.png"
          "--transition-type"
          "grow"
          "--transition-duration"
          "2"
        ];
      }
    ];

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 10.0;
          top-right = 10.0;
          bottom-left = 10.0;
          bottom-right = 10.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [ { app-id = "pavucontrol"; } ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "nm-connection-editor"; } ];
        open-floating = true;
      }
      {
        matches = [
          {
            app-id = "firefox";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "zen"; } ];
        open-on-workspace = "browser";
      }
      {
        matches = [ { app-id = "firefox"; } ];
        excludes = [ { title = "^Picture-in-Picture$"; } ];
        open-on-workspace = "browser";
      }
      {
        matches = [ { app-id = "^discord$"; } ];
        open-on-workspace = "chat";
      }
      {
        matches = [ { app-id = "^Spotify$"; } ];
        open-on-workspace = "media";
      }
    ];

    workspaces = {
      "01-main" = { };
      "02-browser" = {
        name = "browser";
      };
      "03-dev" = {
        name = "dev";
      };
      "04-chat" = {
        name = "chat";
      };
      "05-media" = {
        name = "media";
      };
    };

    binds = {
      "Mod+Return" = {
        action.spawn = "${pkgs.kitty}/bin/kitty";
        hotkey-overlay.title = "Open Terminal";
      };
      "Mod+Q" = {
        action.close-window = [ ];
        hotkey-overlay.title = "Close Window";
      };
      "Mod+Shift+E" = {
        action.quit = { };
        hotkey-overlay.title = "Exit Niri";
      };
      "Mod+E" = {
        action.spawn = [
          "${pkgs.kitty}/bin/kitty"
          "-e"
          "yazi"
        ];
        hotkey-overlay.title = "File Manager";
      };
      "Mod+D" = {
        action.spawn = [
          "rofi"
          "-show"
          "drun"
          "-show-icons"
        ];
        hotkey-overlay.title = "App Launcher";
      };
      "Mod+V" = {
        action.toggle-window-floating = [ ];
        hotkey-overlay.title = "Toggle Floating";
      };
      "Mod+F" = {
        action.maximize-column = [ ];
        hotkey-overlay.title = "Maximize Column";
      };
      "Mod+Shift+F" = {
        action.fullscreen-window = [ ];
        hotkey-overlay.title = "Fullscreen";
      };

      "Mod+R" = {
        action.switch-preset-column-width = [ ];
        hotkey-overlay.title = "Cycle Column Width";
      };
      "Mod+Minus" = {
        action.set-column-width = "-10%";
        hotkey-overlay.title = "Shrink Column";
      };
      "Mod+Equal" = {
        action.set-column-width = "+10%";
        hotkey-overlay.title = "Grow Column";
      };
      "Mod+Shift+Minus" = {
        action.set-window-height = "-10%";
        hotkey-overlay.title = "Shrink Window Height";
      };
      "Mod+Shift+Equal" = {
        action.set-window-height = "+10%";
        hotkey-overlay.title = "Grow Window Height";
      };

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+H" = {
        action.focus-column-left = [ ];
        hotkey-overlay.title = "Focus Left";
      };
      "Mod+L" = {
        action.focus-column-right = [ ];
        hotkey-overlay.title = "Focus Right";
      };
      "Mod+K" = {
        action.focus-window-up = [ ];
        hotkey-overlay.title = "Focus Up";
      };
      "Mod+J" = {
        action.focus-window-down = [ ];
        hotkey-overlay.title = "Focus Down";
      };
      "Mod+Left".hotkey-overlay.hidden = true;
      "Mod+Right".hotkey-overlay.hidden = true;
      "Mod+Up".hotkey-overlay.hidden = true;
      "Mod+Down".hotkey-overlay.hidden = true;

      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H" = {
        action.move-column-left = [ ];
        hotkey-overlay.title = "Move Column Left";
      };
      "Mod+Ctrl+L" = {
        action.move-column-right = [ ];
        hotkey-overlay.title = "Move Column Right";
      };
      "Mod+Shift+K" = {
        action.move-window-up = [ ];
        hotkey-overlay.title = "Move Window Up";
      };
      "Mod+Shift+J" = {
        action.move-window-down = [ ];
        hotkey-overlay.title = "Move Window Down";
      };
      "Mod+Ctrl+Left".hotkey-overlay.hidden = true;
      "Mod+Ctrl+Right".hotkey-overlay.hidden = true;

      "Mod+Comma" = {
        action.consume-or-expel-window-left = [ ];
        hotkey-overlay.title = "Absorb/Expel Left";
      };
      "Mod+Period" = {
        action.consume-or-expel-window-right = [ ];
        hotkey-overlay.title = "Absorb/Expel Right";
      };

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;

      "Mod+Tab" = {
        action.focus-workspace-down = [ ];
        hotkey-overlay.title = "Next Workspace";
      };
      "Mod+Shift+Tab" = {
        action.focus-workspace-up = [ ];
        hotkey-overlay.title = "Previous Workspace";
      };

      "Mod+X" = {
        action.toggle-overview = [ ];
        repeat = false;
      };

      "Mod+T" = {
        action.toggle-column-tabbed-display = [ ];
        hotkey-overlay.title = "Toggle Tabbed";
      };

      "Print" = {
        action.spawn = [ (builtins.toString screenshot-region) ];
        hotkey-overlay.title = "Screenshot Region";
      };
      "Mod+Print" = {
        action.screenshot-screen = [ ];
        hotkey-overlay.title = "Screenshot Screen";
      };
      "Mod+S" = {
        action.screenshot = [ ];
        hotkey-overlay.title = "Screenshot Window";
      };

      "Mod+Shift+V" = {
        action.spawn = [
          "sh"
          "-c"
          "cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ];
        hotkey-overlay.title = "Clipboard History";
      };
      "Mod+Shift+C" = {
        action.spawn = [ (builtins.toString color-picker) ];
        hotkey-overlay.title = "Color Picker";
      };
      "Mod+Shift+W" = {
        action.spawn = [ (builtins.toString wallpaper-cycle) ];
        hotkey-overlay.title = "Cycle Wallpaper";
      };

      "XF86AudioMute" = {
        action.spawn = [
          "pamixer"
          "-t"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };
      "XF86AudioRaiseVolume" = {
        action.spawn = [
          "pamixer"
          "-i"
          "5"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };
      "XF86AudioLowerVolume" = {
        action.spawn = [
          "pamixer"
          "-d"
          "5"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };
      "XF86AudioPlay" = {
        action.spawn = [
          "playerctl"
          "play-pause"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };
      "XF86AudioNext" = {
        action.spawn = [
          "playerctl"
          "next"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };
      "XF86AudioPrev" = {
        action.spawn = [
          "playerctl"
          "previous"
        ];
        allow-when-locked = true;
        hotkey-overlay.hidden = true;
      };

      "Mod+Shift+H" = {
        action.focus-monitor-left = [ ];
        hotkey-overlay.title = "Focus Monitor Left";
      };
      "Mod+Shift+L" = {
        action.focus-monitor-right = [ ];
        hotkey-overlay.title = "Focus Monitor Right";
      };
      "Mod+Ctrl+Shift+H" = {
        action.move-column-to-monitor-left = [ ];
        hotkey-overlay.title = "Move to Monitor Left";
      };
      "Mod+Ctrl+Shift+L" = {
        action.move-column-to-monitor-right = [ ];
        hotkey-overlay.title = "Move to Monitor Right";
      };

      "Mod+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = [ ];
        hotkey-overlay.title = "Toggle Shortcut Inhibit";
      };

      "Mod+Shift+Slash" = {
        action.show-hotkey-overlay = [ ];
        hotkey-overlay.title = "Show This Overlay";
      };
    };
  };
}
