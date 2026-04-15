# Core niri wrapper — workspaces, keybinds, layout, window-rules, animations.
# Shell-agnostic: no bar, no device-specific outputs.
{ pkgs, wlib }:
let
  screenshot-region = pkgs.writeShellScript "niri-screenshot-region" ''
    grim -g "$(slurp)" - | swappy -f -
  '';

  color-picker = pkgs.writeShellScript "niri-color-picker" ''
    grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
    notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
  '';

  wallpaper-cycle = pkgs.writeShellScript "niri-wallpaper-cycle" ''
    img="$(find ~/Pictures/wallpapers -type f | shuf -n1)"
    ${pkgs.awww}/bin/awww img "$img" --transition-type grow --transition-pos cursor --transition-duration 2
  '';

  cliphist-cmd = "cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | cliphist decode | wl-copy";

  niriBase = (wlib.evalModule wlib.wrapperModules.niri).config;
in
niriBase.apply {
  inherit pkgs;
  v2-settings = true;

  settings = {
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = _: { };
    screenshot-path = "~/Pictures/Screenshots/Screenshot %Y-%m-%d %H-%M-%S.png";

    environment = {
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      DISPLAY = ":0";
    };

    input = {
      keyboard.xkb.layout = "us";
      focus-follows-mouse = _: { };
      warp-mouse-to-focus = _: { };
      workspace-auto-back-and-forth = _: { };
    };

    cursor = {
      xcursor-size = 24;
      hide-when-typing = _: { };
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
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; }
      ];
      default-column-width.proportion = 0.5;
      focus-ring.off = _: { };
      border = {
        width = 2;
        active-color = "#cba6f7";
        inactive-color = "#585b70";
        urgent-color = "#f38ba8";
      };
      shadow = {
        on = _: { };
        softness = 12;
        spread = 5;
        offset = _: {
          props = {
            x = 0;
            y = 5;
          };
        };
        draw-behind-window = false;
        color = "#1a1a2ecc";
        inactive-color = "#1a1a2e66";
      };
    };

    overview.zoom = 0.5;

    animations = {
      slowdown = 1.0;
      workspace-switch.spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      window-open = {
        duration-ms = 200;
        curve = "ease-out-expo";
      };
      window-close = {
        duration-ms = 150;
        curve = "ease-out-quad";
      };
      horizontal-view-movement.spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      window-movement.spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      window-resize.spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      config-notification-open-close.spring = _: {
        props = {
          damping-ratio = 0.6;
          stiffness = 1000;
          epsilon = 0.001;
        };
      };
    };

    # Startup daemons (shell-agnostic — bar is added per-shell)
    spawn-at-startup = [
      [
        "nm-applet"
        "--indicator"
      ]
      [
        "${pkgs.wl-clipboard}/bin/wl-paste"
        "--type"
        "text"
        "--watch"
        "cliphist"
        "store"
      ]
      [
        "${pkgs.wl-clipboard}/bin/wl-paste"
        "--type"
        "image"
        "--watch"
        "cliphist"
        "store"
      ]
      "/run/current-system/sw/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
      "${pkgs.awww}/bin/awww-daemon"
    ];

    spawn-sh-at-startup = [
      "${pkgs.awww}/bin/awww img ~/Pictures/wallpaper.png --transition-type grow --transition-duration 2"
    ];

    window-rules = [
      {
        matches = [ { } ];
        geometry-corner-radius = [
          10.0
          10.0
          10.0
          10.0
        ];
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
        excludes = [
          {
            app-id = "firefox";
            title = "^Picture-in-Picture$";
          }
        ];
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
      "main" = _: { };
      "browser" = _: { };
      "dev" = _: { };
      "chat" = _: { };
      "media" = _: { };
    };

    binds = {
      # Launch
      "Mod+Return".spawn = "${pkgs.kitty}/bin/kitty";
      "Mod+E".spawn = [
        "${pkgs.kitty}/bin/kitty"
        "-e"
        "yazi"
      ];
      "Mod+D".spawn = [
        "${pkgs.rofi}/bin/rofi"
        "-show"
        "drun"
        "-show-icons"
      ];

      # Window management
      "Mod+Q".close-window = _: { };
      "Mod+Shift+E".quit = _: { };
      "Mod+V".toggle-window-floating = _: { };
      "Mod+F".maximize-column = _: { };
      "Mod+Shift+F".fullscreen-window = _: { };

      # Column sizing
      "Mod+R".switch-preset-column-width = _: { };
      "Mod+Minus".set-column-width = "-10%";
      "Mod+Equal".set-column-width = "+10%";
      "Mod+Shift+Minus".set-window-height = "-10%";
      "Mod+Shift+Equal".set-window-height = "+10%";

      # Focus
      "Mod+Left".focus-column-left = _: { };
      "Mod+Right".focus-column-right = _: { };
      "Mod+Up".focus-window-up = _: { };
      "Mod+Down".focus-window-down = _: { };
      "Mod+H".focus-column-left = _: { };
      "Mod+L".focus-column-right = _: { };
      "Mod+K".focus-window-up = _: { };
      "Mod+J".focus-window-down = _: { };

      # Move
      "Mod+Ctrl+Left".move-column-left = _: { };
      "Mod+Ctrl+Right".move-column-right = _: { };
      "Mod+Ctrl+H".move-column-left = _: { };
      "Mod+Ctrl+L".move-column-right = _: { };
      "Mod+Shift+K".move-window-up = _: { };
      "Mod+Shift+J".move-window-down = _: { };

      # Absorb / expel
      "Mod+Comma".consume-or-expel-window-left = _: { };
      "Mod+Period".consume-or-expel-window-right = _: { };

      # Workspaces
      "Mod+1".focus-workspace = 1;
      "Mod+2".focus-workspace = 2;
      "Mod+3".focus-workspace = 3;
      "Mod+4".focus-workspace = 4;
      "Mod+5".focus-workspace = 5;
      "Mod+6".focus-workspace = 6;
      "Mod+7".focus-workspace = 7;
      "Mod+8".focus-workspace = 8;
      "Mod+9".focus-workspace = 9;

      "Mod+Shift+1".move-column-to-workspace = 1;
      "Mod+Shift+2".move-column-to-workspace = 2;
      "Mod+Shift+3".move-column-to-workspace = 3;
      "Mod+Shift+4".move-column-to-workspace = 4;
      "Mod+Shift+5".move-column-to-workspace = 5;
      "Mod+Shift+6".move-column-to-workspace = 6;
      "Mod+Shift+7".move-column-to-workspace = 7;
      "Mod+Shift+8".move-column-to-workspace = 8;
      "Mod+Shift+9".move-column-to-workspace = 9;

      "Mod+Tab".focus-workspace-down = _: { };
      "Mod+Shift+Tab".focus-workspace-up = _: { };

      "Mod+X" = _: {
        props.repeat = false;
        content.toggle-overview = _: { };
      };
      "Mod+T".toggle-column-tabbed-display = _: { };

      # Screenshots
      "Print".screenshot = _: { };
      "Mod+Print".screenshot-screen = _: { };
      "Mod+S".screenshot-window = _: { };

      # Clipboard & utilities
      "Mod+Shift+V".spawn-sh = cliphist-cmd;
      "Mod+Shift+C".spawn = "${color-picker}";
      "Mod+Shift+W".spawn = "${wallpaper-cycle}";

      # Media keys
      "XF86AudioMute" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "pamixer"
          "-t"
        ];
      };
      "XF86AudioRaiseVolume" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "pamixer"
          "-i"
          "5"
        ];
      };
      "XF86AudioLowerVolume" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "pamixer"
          "-d"
          "5"
        ];
      };
      "XF86AudioPlay" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "playerctl"
          "play-pause"
        ];
      };
      "XF86AudioNext" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "playerctl"
          "next"
        ];
      };
      "XF86AudioPrev" = _: {
        props.allow-when-locked = true;
        content.spawn = [
          "playerctl"
          "previous"
        ];
      };

      # Monitors
      "Mod+Shift+H".focus-monitor-left = _: { };
      "Mod+Shift+L".focus-monitor-right = _: { };
      "Mod+Ctrl+Shift+H".move-column-to-monitor-left = _: { };
      "Mod+Ctrl+Shift+L".move-column-to-monitor-right = _: { };

      "Mod+Escape" = _: {
        props.allow-inhibiting = false;
        content.toggle-keyboard-shortcuts-inhibit = _: { };
      };
      "Mod+Shift+Slash".show-hotkey-overlay = _: { };
    };
  };
}
