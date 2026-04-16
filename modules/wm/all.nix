{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../wayland
  ];

  # DMS (Dank Material Shell) runtime requirements:
  # geoclue2 for automatic location, accounts-daemon for user info
  services.geoclue2.enable = lib.mkDefault true;
  services.accounts-daemon.enable = lib.mkDefault true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = [ ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  environment.systemPackages = with pkgs; [
    (lib.hiPrio niri-configured)
    niri-dms
    niri-noct
    dms-shell # DMS QML calls `dms dl` for network ops (location search, etc.)
    libsecret
    seahorse
    polkit_gnome
    xwayland-satellite
    waybar
    rofi
    dunst
    swaylock-effects
    swayidle
  ];
}
