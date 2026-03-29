# HTPC module — Jellyfin server + couch-friendly desktop
#
# Goals:
#   - Auto-login to a couch-optimized session
#   - Steam Big Picture as the primary gaming interface
#   - Jellyfin server for media streaming to other devices
#   - Controller-friendly (gamepad navigation)
#   - Minimal desktop — just enough to launch apps from the couch
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.htpc;
in
{
  options.my.htpc = {
    enable = lib.mkEnableOption "HTPC couch-friendly media center";

    user = lib.mkOption {
      type = lib.types.str;
      default = config.my.username;
      description = "User to auto-login and run HTPC services as.";
    };

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/media";
      description = "Root directory for media files (movies, TV, music).";
    };

    jellyfin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Jellyfin media server.";
      };
    };

    steam = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Steam with Big Picture mode.";
      };

      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Auto-launch Steam Big Picture on login.";
      };
    };

    kiosk = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Kiosk mode — boot straight into Steam Big Picture (no desktop).";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # --- Always enabled ---
    {
      # Auto-login
      services.displayManager.autoLogin = {
        enable = true;
        user = cfg.user;
      };

      # Gamepad / controller support
      hardware.steam-hardware.enable = cfg.steam.enable;
      services.udev.packages = [ pkgs.game-devices-udev-rules ];

      # Bluetooth for wireless controllers
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # CEC — control HTPC with TV remote
      environment.systemPackages = with pkgs; [
        libcec       # HDMI-CEC control
        playerctl    # Media key support
        firefox      # Couch browsing
      ];

      # SSH for remote management
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };
    }

    # --- Jellyfin server ---
    (lib.mkIf cfg.jellyfin.enable {
      services.jellyfin = {
        enable = true;
        user = cfg.user;
        group = "users";
        openFirewall = true;
      };

      # Hardware-accelerated transcoding (VA-API)
      environment.systemPackages = with pkgs; [
        jellyfin-ffmpeg # Jellyfin's patched ffmpeg with hw accel
      ];
    })

    # --- Steam ---
    (lib.mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        gamescopeSession = {
          enable = true; # Gamescope compositor for games
        };
      };

      # Gamescope — optimized game compositor (HDR, FSR, frame limiting)
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      environment.systemPackages = with pkgs; [
        mangohud     # Performance overlay
        gamemode     # Feral GameMode for performance
        protonup-qt  # Manage Proton versions
      ];

      # GameMode service
      programs.gamemode = {
        enable = true;
        enableRenice = true;
      };
    })

    # --- Kiosk mode (Steam Big Picture as the session) ---
    (lib.mkIf cfg.kiosk.enable {
      # Use gamescope session directly — boots into Steam Big Picture
      # No traditional desktop environment needed
      services.displayManager.defaultSession = "gamescope-wayland";
    })

    # --- Non-kiosk: regular desktop with couch-friendly tweaks ---
    (lib.mkIf (!cfg.kiosk.enable) {
      # KDE Plasma — good couch UX with controller support
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Large cursor, touch-friendly
      environment.systemPackages = with pkgs; [
        kdePackages.kate
      ];
    })

    # --- Auto-start Steam Big Picture (non-kiosk) ---
    (lib.mkIf (cfg.steam.autoStart && !cfg.kiosk.enable) {
      # XDG autostart entry for Steam Big Picture
      environment.etc."xdg/autostart/steam-big-picture.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Steam Big Picture
        Exec=steam -bigpicture
        X-GNOME-Autostart-enabled=true
      '';
    })
  ]);
}
