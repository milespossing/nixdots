{ config, inputs, ... }:
let
  # The flake-parts config — captured so the inner home-manager module (which
  # shadows `config` with the HM config to reach `config.lib.niri.actions`) can
  # still reach the wrappers registry and sibling buckets.
  flakeCfg = config;
in
{
  # niri (scrollable-tiling wayland) — euler's WM. Pulls the wayland layer
  # (→ desktop-core) and the niri-flake NixOS module; the matching home-manager
  # bucket carries the KDL settings via niri-flake's `programs.niri.settings`.
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [
        flakeCfg.flake.modules.nixos.desktop-wayland
        inputs.niri.nixosModules.niri
      ];

      programs.niri.enable = true;

      # X11 apps under niri + screencast portal.
      environment.systemPackages = [ pkgs.xwayland-satellite ];
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

  flake.modules.homeManager.niri =
    {
      pkgs,
      config,
      ...
    }:
    let
      color-picker = pkgs.writeShellScript "niri-color-picker" ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -p)" -t ppm - \
          | ${pkgs.imagemagick}/bin/magick - -format '%[pixel:p{0,0}]' txt:- \
          | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
      '';

      cliphist-cmd = "${pkgs.cliphist}/bin/cliphist list | rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
    in
    {
      imports = [
        flakeCfg.flake.modules.homeManager.desktop-wayland
      ];
      # NB: niri-flake's NixOS module auto-injects its home-manager module into
      # every user, so `programs.niri.settings` + `config.lib.niri.actions` are
      # already available here — importing homeModules.config would double-declare.

      home.packages = [
        (flakeCfg.flake.wrappers.rofi.wrap { inherit pkgs; })
        (flakeCfg.flake.wrappers.swaylock-effects.wrap { inherit pkgs; })
        (flakeCfg.flake.wrappers.noctalia.wrap { inherit pkgs; })
      ];

      programs.niri.settings = {
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/Screenshot %Y-%m-%d %H-%M-%S.png";
        hotkey-overlay.skip-at-startup = true;

        environment = {
          XDG_SESSION_TYPE = "wayland";
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
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];
          default-column-width.proportion = 0.5;
          focus-ring.enable = false;
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

        overview.zoom = 0.5;

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

        # Startup daemons. The bar (noctalia) lives here too; clipboard
        # watchers + polkit agent + xwayland-satellite round out the session.
        spawn-at-startup = [
          {
            command = [
              "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
              ":0"
            ];
          }
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
              "${pkgs.cliphist}/bin/cliphist"
              "store"
            ];
          }
          {
            command = [
              "${pkgs.wl-clipboard}/bin/wl-paste"
              "--type"
              "image"
              "--watch"
              "${pkgs.cliphist}/bin/cliphist"
              "store"
            ];
          }
          { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
          { command = [ "noctalia" ]; }
        ];

        window-rules = [
          {
            matches = [ { } ];
            geometry-corner-radius = {
              top-left = 10.0;
              top-right = 10.0;
              bottom-right = 10.0;
              bottom-left = 10.0;
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

        # Named workspaces. Keys are numeric-prefixed to fix their order (niri
        # sorts workspaces by key); `name` is the friendly handle referenced by
        # window-rules' open-on-workspace. Host modules pin them to outputs.
        workspaces = {
          "1-main".name = "main";
          "2-browser".name = "browser";
          "3-dev".name = "dev";
          "4-chat".name = "chat";
          "5-media".name = "media";
        };

        binds = with config.lib.niri.actions; {
          # Launch
          "Mod+Return".action = spawn "kitty";
          "Mod+E".action = spawn "kitty" "-e" "yazi";
          "Mod+D".action = spawn "rofi" "-show" "drun" "-show-icons";

          # Window management
          "Mod+Q".action = close-window;
          "Mod+Shift+E".action = quit;
          "Mod+V".action = toggle-window-floating;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;

          # Column sizing
          "Mod+R".action = switch-preset-column-width;
          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";
          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Equal".action = set-window-height "+10%";

          # Focus
          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Up".action = focus-window-up;
          "Mod+Down".action = focus-window-down;
          "Mod+H".action = focus-column-left;
          "Mod+L".action = focus-column-right;
          "Mod+K".action = focus-window-up;
          "Mod+J".action = focus-window-down;

          # Move
          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+Shift+K".action = move-window-up;
          "Mod+Shift+J".action = move-window-down;

          # Absorb / expel
          "Mod+Comma".action = consume-or-expel-window-left;
          "Mod+Period".action = consume-or-expel-window-right;

          # Workspaces
          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          "Mod+Tab".action = focus-workspace-down;
          "Mod+Shift+Tab".action = focus-workspace-up;

          "Mod+X" = {
            repeat = false;
            action = toggle-overview;
          };
          "Mod+T".action = toggle-column-tabbed-display;

          # Screenshots (these niri actions take optional args, so they're set
          # via .action.<name> rather than the magic-leaf helpers).
          "Print".action.screenshot = { };
          "Mod+Print".action.screenshot-screen = { };
          "Mod+S".action.screenshot-window = { };

          # Clipboard & utilities
          "Mod+Shift+V".action = spawn-sh cliphist-cmd;
          "Mod+Shift+C".action = spawn "${color-picker}";

          # Media keys
          "XF86AudioMute" = {
            allow-when-locked = true;
            action = spawn "pamixer" "-t";
          };
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action = spawn "pamixer" "-i" "5";
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action = spawn "pamixer" "-d" "5";
          };
          "XF86AudioPlay" = {
            allow-when-locked = true;
            action = spawn "playerctl" "play-pause";
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            action = spawn "playerctl" "next";
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action = spawn "playerctl" "previous";
          };

          # Monitors
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+L".action = focus-monitor-right;
          "Mod+Ctrl+Shift+H".action = move-column-to-monitor-left;
          "Mod+Ctrl+Shift+L".action = move-column-to-monitor-right;

          "Mod+Escape" = {
            allow-inhibiting = false;
            action = toggle-keyboard-shortcuts-inhibit;
          };
          "Mod+Shift+Slash".action = show-hotkey-overlay;
        };
      };
    };
}
