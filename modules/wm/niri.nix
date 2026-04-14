{ pkgs, inputs, ... }:
{
  imports = [
    ../wayland
    inputs.niri.nixosModules.niri
  ];

  # Use niri-stable for programs.niri — the NixOS module needs cargo
  # build attrs for portal detection. The wrapped version (niri-configured)
  # is installed separately and carries the baked-in KDL config via NIRI_CONFIG.
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri-configured}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  environment.systemPackages = with pkgs; [
    niri-configured
    libsecret
    seahorse
    polkit_gnome
    xwayland-satellite
  ];
}
