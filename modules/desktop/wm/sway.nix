{ config, ... }:
{
  # sway (wayland) — laplace's WM. Pulls the wayland layer (→ desktop-core).
  flake.modules.nixos.sway =
    { pkgs, ... }:
    {
      imports = [ config.flake.modules.nixos.desktop-wayland ];

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraOptions = [ "--unsupported-gpu" ];
      };
      services.displayManager.defaultSession = "sway";
    };

  flake.modules.homeManager.sway =
    { pkgs, ... }:
    let
      mod = "Mod4";
      terminal = "kitty";
      menu = "rofi -show drun -show-icons";
    in
    {
      imports = [ config.flake.modules.homeManager.desktop-wayland ];

      home.packages = [
        (config.flake.wrappers.rofi.wrap { inherit pkgs; })
        (config.flake.wrappers.waybar.wrap { inherit pkgs; })
        (config.flake.wrappers.swaylock-effects.wrap { inherit pkgs; })
      ];

      wayland.windowManager.sway = {
        enable = true;
        package = pkgs.swayfx;
        checkConfig = false;
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
            outer = 5;
          };
          window.titlebar = false;
          input."*".xkb_layout = "us";
          focus.followMouse = true;
          bars = [ { command = "waybar"; } ];
          startup = [
            { command = "nm-applet --indicator"; }
          ];
          keybindings = {
            "${mod}+Return" = "exec ${terminal}";
            "${mod}+q" = "kill";
            "${mod}+d" = "exec ${menu}";
            "${mod}+e" = "exec ${terminal} -e yazi";
            "${mod}+v" = "floating toggle";
            "${mod}+f" = "fullscreen";
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";
            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "Print" = ''exec grim -g "$(slurp)" - | swappy -f -'';
            "XF86AudioMute" = "exec pamixer -t";
            "XF86AudioRaiseVolume" = "exec pamixer -i 5";
            "XF86AudioLowerVolume" = "exec pamixer -d 5";
          };
        };
        extraSessionCommands = ''
          export NIXOS_OZONE_WL=1
          export ELECTRON_OZONE_PLATFORM_HINT=auto
        '';
      };
    };
}
