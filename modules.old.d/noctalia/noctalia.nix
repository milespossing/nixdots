{
  pkgs,
  wlib,
  basePackage ? pkgs.noctalia-shell,
}:
wlib.evalPackage [
  wlib.wrapperModules.noctalia-shell
  {
    inherit pkgs;
    package = basePackage;

    # Seed config to ~/.config/noctalia so the GUI settings editor still works.
    # Files that already exist at runtime are never overwritten.
    outOfStoreConfig = "~/.config/noctalia";

    settings = {
      appLauncher = {
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWrapText = true;
        enableClipPreview = true;
        enableClipboardChips = true;
        enableClipboardSmartIcons = true;
        enableSessionSearch = true;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        iconMode = "tabler";
        position = "center";
        showCategories = true;
        sortByMostUsed = true;
        terminalCommand = "${pkgs.kitty}/bin/kitty -e";
        viewMode = "list";
      };

      audio = {
        spectrumFrameRate = 30;
        spectrumMirrored = true;
        visualizerType = "linear";
        volumeStep = 5;
      };

      bar = {
        backgroundOpacity = 0.93;
        barType = "simple";
        contentPadding = 2;
        displayMode = "always_visible";
        enableExclusionZoneInset = true;
        frameRadius = 12;
        frameThickness = 8;
        marginHorizontal = 4;
        marginVertical = 4;
        outerCorners = true;
        position = "top";
        rightClickAction = "controlCenter";
        rightClickFollowMouse = true;
        showCapsule = true;
        showOnWorkspaceSwitch = true;
        widgetSpacing = 6;
        widgets = {
          center = [
            {
              characterCount = 2;
              enableScrollWheel = true;
              focusedColor = "primary";
              fontWeight = "bold";
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "index";
              occupiedColor = "secondary";
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
            }
          ];
          left = [
            {
              icon = "rocket";
              id = "Launcher";
            }
            {
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              id = "Clock";
            }
            {
              compactMode = true;
              id = "SystemMonitor";
              showCpuTemp = true;
              showCpuUsage = true;
              showMemoryUsage = true;
              useMonospaceFont = true;
            }
            {
              hideMode = "hidden";
              id = "ActiveWindow";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              showText = true;
            }
            {
              hideMode = "hidden";
              id = "MediaMini";
              maxWidth = 145;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
            }
          ];
          right = [
            {
              drawerEnabled = true;
              id = "Tray";
            }
            {
              id = "NotificationHistory";
              showUnreadBadge = true;
              unreadBadgeColor = "primary";
            }
            {
              displayMode = "graphic-clean";
              hideIfNotDetected = true;
              id = "Battery";
            }
            {
              displayMode = "onhover";
              id = "Volume";
              middleClickCommand = "pwvucontrol || pavucontrol";
            }
            {
              displayMode = "onhover";
              id = "Brightness";
            }
            {
              icon = "noctalia";
              id = "ControlCenter";
            }
          ];
        };
      };

      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
      };

      colorSchemes = {
        darkMode = true;
        predefinedScheme = "Catppuccin";
        syncGsettings = true;
      };

      controlCenter = {
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = false;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };
      };

      dock = {
        displayMode = "auto_hide";
        dockType = "floating";
        enabled = true;
        indicatorColor = "primary";
        indicatorThickness = 3;
        onlySameOutput = true;
        position = "bottom";
        showDockIndicator = true;
      };

      general = {
        allowPanelsOnScreenWithoutBar = true;
        animationSpeed = 1;
        enableBlurBehind = true;
        enableLockScreenCountdown = true;
        enableShadows = true;
        lockOnSuspend = true;
        radiusRatio = 1;
        smoothScrollEnabled = true;
        telemetryEnabled = false;
      };

      idle = {
        enabled = false;
      };

      notifications = {
        backgroundOpacity = 1;
        clearDismissed = true;
        enabled = true;
        location = "top_right";
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
        overlayLayer = true;
      };

      osd = {
        enabled = true;
        location = "top_right";
        overlayLayer = true;
      };

      sessionMenu = {
        enableCountdown = true;
        largeButtonsStyle = true;
        position = "center";
        showHeader = true;
        showKeybinds = true;
      };

      ui = {
        fontFixed = "FiraCode Nerd Font Mono";
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = true;
        tooltipsEnabled = true;
      };

      wallpaper = {
        directory = "/home/miles/Pictures/Wallpapers";
        enabled = true;
        fillMode = "crop";
        setWallpaperOnAllMonitors = true;
        transitionDuration = 1500;
        transitionType = [
          "fade"
          "disc"
          "stripes"
          "wipe"
          "pixelate"
          "honeycomb"
        ];
        wallpaperChangeMode = "random";
      };
    };

    # Catppuccin Mocha color scheme
    colors = {
      mError = "#f38ba8";
      mHover = "#94e2d5";
      mOnError = "#11111b";
      mOnHover = "#11111b";
      mOnPrimary = "#11111b";
      mOnSecondary = "#11111b";
      mOnSurface = "#cdd6f4";
      mOnSurfaceVariant = "#a3b4eb";
      mOnTertiary = "#11111b";
      mOutline = "#4c4f69";
      mPrimary = "#cba6f7";
      mSecondary = "#fab387";
      mShadow = "#11111b";
      mSurface = "#1e1e2e";
      mSurfaceVariant = "#313244";
      mTertiary = "#94e2d5";
    };

    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = { };
      version = 2;
    };
  }
]
