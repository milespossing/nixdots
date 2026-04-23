{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../wayland
  ];

  # Ensure wayland-sessions desktop entries (e.g. niri-configured) are
  # linked into /run/current-system/sw so tuigreet can discover them.
  environment.pathsToLink = [ "/share/wayland-sessions" ];

  # Noctalia runtime requirements:
  # geoclue2 for automatic location, accounts-daemon for user info
  services.geoclue2.enable = lib.mkDefault true;
  services.accounts-daemon.enable = lib.mkDefault true;

  # dconf is needed by home-manager for GTK/cursor theme settings
  programs.dconf.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # Removable media support (udisks2 D-Bus API + gvfs virtual filesystem)
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  environment.systemPackages = with pkgs; [
    (lib.hiPrio niri-configured)
    libsecret
    seahorse
    polkit_gnome
    xwayland-satellite
    rofi
  ];
}
