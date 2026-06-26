# let
#   color-picker = pkgs.writeShellScript "niri-color-picker" ''
#     ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -p)" -t ppm - \
#       | ${pkgs.imagemagick}/bin/magick - -format '%[pixel:p{0,0}]' txt:- \
#       | tail -1 | grep -oP '#[0-9a-fA-F]+' | ${pkgs.wl-clipboard}/bin/wl-copy
#     ${pkgs.libnotify}/bin/notify-send "Color Picker" "$(${pkgs.wl-clipboard}/bin/wl-paste)"
#   '';
#
#   cliphist-cmd = "${pkgs.cliphist}/bin/cliphist list | rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
# in
{ config, lib, ... }:
let
  flake = config.flake;
in
{
  flake.wrappers.niri =
    {
      config,
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.niri ];

      env = {
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0";
      };

      settings = {
        prefer-no-csd = { };
        screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";
        hotkey-overlay.skip-at-startup = { };
        input = {
          keyboard.xkb.layout = "us";
          focus-follows-mouse = { };
          warp-mouse-to-focus = { };
          workspace-auto-back-and-forth = { };
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
          focus-ring = {
            width = 0.5;
          };
          border = {
            width = 0.5;
            active-color = "#cba6f7";
            inactive-color = "#585b70";
            urgent-color = "#f38ba8";
          };
          shadow = {
            on = { };
            softness = 12;
            spread = 5;
            offset = _: {
              params = {
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

        spawn-at-startup = [
          [
            "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
            ":0"
          ]
          [
            "nm-applet"
            "--indicator"
          ]
          [
            "${pkgs.wl-clipboard}/bin/wl-paste"
            "--type"
            "text"
            "--watch"
            "${pkgs.cliphist}/bin/cliphist"
            "store"
          ]
          [
            "${pkgs.wl-clipboard}/bin/wl-paste"
            "--type"
            "image"
            "--watch"
            "${pkgs.cliphist}/bin/cliphist"
            "store"
          ]
          [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]
          [ (lib.getExe (flake.wrappers.noctalia.wrap { inherit pkgs; })) ]
        ];

        window-rules = [
          {
            matches = [ { } ];
            geometry-corner-radius = 10;
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
          "1-main" = { };
          "2-browser" = { };
          "3-dev" = { };
          "4-chat" = { };
          "5-media" = { };
        };

        binds =
          let
            kitty = lib.getExe (flake.wrappers.kitty.wrap { inherit pkgs; });
            rofi = lib.getExe (flake.wrappers.rofi.wrap { inherit pkgs; });
            basicAction = a: { "${a}" = { }; };
            action = a: v: { "${a}" = v; };
            columnWidth = s: action "set-column-width" s;
            columnHeight = s: action "set-window-height" s;
          in
          {
            "Mod+Return".spawn = kitty;
            "Mod+E".spawn = [
              kitty
              "-e"
              "yazi"
            ];
            "Mod+D".spawn = [
              rofi
              "-show"
              "drun"
              "-show-icons"
            ];

            # Nav
            "Mod+H" = basicAction "focus-column-left";
            "Mod+L" = basicAction "focus-column-right";
            "Mod+K" = basicAction "focus-window-up";
            "Mod+J" = basicAction "focus-window-down";

            # Window Management
            "Mod+Q" = basicAction "close-window";
            "Mod+Shift+E" = basicAction "quit";
            "Mod+V" = basicAction "toggle-window-floating";
            "Mod+F" = basicAction "maximize-column";
            "Mod+Shift+F" = basicAction "fullscreen-window";
            "Mod+Comma" = basicAction "consume-or-expel-window-left";
            "Mod+Period" = basicAction "consume-or-expel-window-right";

            # Workspaces
            "Mod+1" = action "focus-workspace" 1;
            "Mod+2" = action "focus-workspace" 2;
            "Mod+3" = action "focus-workspace" 3;
            "Mod+4" = action "focus-workspace" 4;
            "Mod+5" = action "focus-workspace" 5;
            "Mod+6" = action "focus-workspace" 6;
            "Mod+7" = action "focus-workspace" 7;
            "Mod+8" = action "focus-workspace" 8;
            "Mod+9" = action "focus-workspace" 9;

            "Mod+Shift+1" = action "move-column-to-workspace" 1;
            "Mod+Shift+2" = action "move-column-to-workspace" 2;
            "Mod+Shift+3" = action "move-column-to-workspace" 3;
            "Mod+Shift+4" = action "move-column-to-workspace" 4;
            "Mod+Shift+5" = action "move-column-to-workspace" 5;
            "Mod+Shift+6" = action "move-column-to-workspace" 6;
            "Mod+Shift+7" = action "move-column-to-workspace" 7;
            "Mod+Shift+8" = action "move-column-to-workspace" 8;
            "Mod+Shift+9" = action "move-column-to-workspace" 9;

            # Column sizing
            "Mod+R" = basicAction "switch-preset-column-width";
            "Mod+Minus" = columnWidth "-10%";
            "Mod+Equal" = columnWidth "+10%";
            "Mod+Shift+Minus" = columnHeight "-10%";
            "Mod+Shift+Equal" = columnHeight "+10%";
            "Mod+Tab".focus-workspace-down = { };
            "Mod+Shift+Tab".focus-workspace-up = { };

            "Mod+X" = _: {
              props.repeat = false;
              content.toggle-overview = { };
            };
            "Mod+T".toggle-column-tabbed-display = { };
            "Mod+Shift+H".focus-monitor-left = { };
            "Mod+Shift+L".focus-monitor-right = { };
            "Mod+Shift+Slash".show-hotkey-overlay = { };
          };
      };
    };

  # NixOS side: pull in the wayland layer (greetd + tuigreet live there), then
  # install the *wrapped* niri into the system profile. That package ships the
  # wayland-session .desktop, the niri-session helper, and a niri.service whose
  # ExecStart points back at the wrapped binary (so NIRI_CONFIG — and thus the
  # whole config, including this host's outputs — applies). Putting it in
  # systemPackages is what makes the session show up in the greeter
  # (/run/current-system/sw/share/wayland-sessions).
  flake.modules.nixos.niri =
    { config, pkgs, ... }:
    {
      imports = [ flake.modules.nixos.desktop-wayland ];

      options.desktop = {
        outputs = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Per-host niri output (monitor) configuration.";
        };
        workspaces = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Per-host niri named-workspace pinning.";
        };
      };

      config = {
        environment.systemPackages = [
          pkgs.xwayland-satellite
          (flake.wrappers.niri.wrap {
            inherit pkgs;
            settings = {
              outputs = config.desktop.outputs;
              workspaces = config.desktop.workspaces;
            };
          })
        ];
        xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        # niri spawns polkit-gnome at startup; it needs the polkit daemon.
        security.polkit.enable = true;
      };
    };

  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      imports = [
        flake.modules.homeManager.desktop-wayland
      ];

      # niri itself comes from the system profile (above). The session shell
      # (noctalia bar) and the lock screen are per-user.
      home.packages = [
        (flake.wrappers.swaylock.wrap { inherit pkgs; })
        (flake.wrappers.noctalia.wrap { inherit pkgs; })
      ];
    };
}
