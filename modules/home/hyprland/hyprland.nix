{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun -show-icons";

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NIXOS_OZONE_WL,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      cursor = {
        no_hardware_cursors = true;
        warp_on_change_workspace = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ff) rgba(89b4faff) 45deg";
        "col.inactive_border" = "rgba(585b70ff)";
        layout = "dwindle";
        allow_tearing = true;
      };

      group = {
        "col.border_active" = "rgba(cba6f7ff)";
        "col.border_inactive" = "rgba(585b70ff)";
        groupbar = {
          font_family = "DepartureMono Nerd Font";
          font_size = 11;
          height = 20;
          "col.active" = "rgba(cba6f7ff)";
          "col.inactive" = "rgba(313244ff)";
          text_color = "rgba(cdd6f4ff)";
        };
      };

      decoration = {
        rounding = 10;
        dim_inactive = true;
        dim_strength = 0.15;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          vibrancy = 0.2;
          noise = 0.02;
          brightness = 0.9;
        };
        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "rgba(1a1a2ecc)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "overshoot, 0.05, 0.9, 0.1, 1.05"
          "smoothIn, 0.25, 0, 0.5, 1"
          "smoothOut, 0, 0.5, 0.75, 1"
        ];
        animation = [
          "windows, 1, 5, overshoot, popin 80%"
          "windowsOut, 1, 4, smoothOut, popin 80%"
          "windowsMove, 1, 4, easeOutQuint"
          "fade, 1, 5, smoothIn"
          "fadeOut, 1, 4, smoothOut"
          "workspaces, 1, 4, easeOutQuint, slidefade 20%"
          "specialWorkspace, 1, 4, overshoot, slidevert"
          "layers, 1, 4, smoothIn, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
      };

      render = {
        direct_scanout = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
      };

      layerrule = [
        "blur on, match:namespace waybar"
        "ignore_alpha 0, match:namespace waybar"
        "blur on, match:namespace rofi"
        "ignore_alpha 0, match:namespace rofi"
        "blur on, match:namespace notifications"
        "ignore_alpha 0, match:namespace notifications"
      ];

      windowrule = [
        "suppress_event maximize, match:class .*"
        "float on, match:class pavucontrol"
        "float on, match:class nm-connection-editor"
        "float on, match:title ^(Picture-in-Picture)$"
        "pin on, match:title ^(Picture-in-Picture)$"
        "workspace 2, match:class firefox"
        "workspace 2, match:class zen"
        "workspace 4, match:class discord"
        "workspace 5, match:class Spotify"
        "float on, match:class ^(scratchterm)$"
        "size 60% 70%, match:class ^(scratchterm)$"
        "center on, match:class ^(scratchterm)$"
        "float on, match:class ^(scratchnotes)$"
        "size 50% 60%, match:class ^(scratchnotes)$"
        "center on, match:class ^(scratchnotes)$"
        "immediate on, match:class ^(steam_app_.*)$"
        "fullscreen on, match:class ^(steam_app_.*)$"
      ];

      workspace = [
        "special:term, on-created-empty:kitty --class scratchterm"
        "special:notes, on-created-empty:kitty --class scratchnotes -e nvim ~/notes/"
        "special:music, on-created-empty:spotify"
      ];

      exec-once = [
        "waybar"
        "nm-applet --indicator"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "${builtins.toString ./scripts/polkit.sh}"
        "${pkgs.awww}/bin/awww-daemon"
        "${pkgs.awww}/bin/awww img ~/Pictures/wallpaper.png --transition-type grow --transition-duration 2"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod SHIFT, E, exit"
        "$mod, E, exec, $terminal -e yazi"
        "$mod, V, togglefloating"
        "$mod, D, exec, $menu"
        "$mod, P, pseudo"
        "$mod, F, fullscreen"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # scratchpads
        "$mod, S, togglespecialworkspace, term"
        "$mod SHIFT, S, movetoworkspace, special:term"
        "$mod, M, togglespecialworkspace, music"
        "$mod, N, togglespecialworkspace, notes"

        # window grouping (tabbed)
        "$mod, T, togglegroup"
        "$mod, Tab, changegroupactive, f"
        "$mod SHIFT, Tab, changegroupactive, b"

        # submaps
        "$mod, R, submap, resize"
        "$mod, O, submap, launch"

        # screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, Print, exec, grim - | swappy -f -"

        # clipboard
        "$mod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # color picker
        "$mod SHIFT, C, exec, hyprpicker -a"

        # wallpaper cycle
        "$mod SHIFT, W, exec, ${pkgs.awww}/bin/awww img \"$(find ~/Pictures/wallpapers -type f | shuf -n1)\" --transition-type grow --transition-pos cursor --transition-duration 2"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindl = [
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
      ];
    };

    extraConfig = ''
      # resize submap
      submap = resize
      binde = , H, resizeactive, -20 0
      binde = , L, resizeactive, 20 0
      binde = , K, resizeactive, 0 -20
      binde = , J, resizeactive, 0 20
      binde = , left, resizeactive, -20 0
      binde = , right, resizeactive, 20 0
      binde = , up, resizeactive, 0 -20
      binde = , down, resizeactive, 0 20
      bind = , escape, submap, reset
      bind = , Return, submap, reset
      submap = reset

      # launch submap
      submap = launch
      bind = , T, exec, $terminal
      bind = , T, submap, reset
      bind = , B, exec, zen
      bind = , B, submap, reset
      bind = , F, exec, $terminal -e yazi
      bind = , F, submap, reset
      bind = , D, exec, discord
      bind = , D, submap, reset
      bind = , S, exec, spotify
      bind = , S, submap, reset
      bind = , P, exec, pavucontrol
      bind = , P, submap, reset
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
