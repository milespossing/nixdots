{ pkgs, inputs, ... }:
{
  imports = [
    ../wayland
    inputs.niri.nixosModules.niri
  ];

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

  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
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
    libsecret
    seahorse
    polkit_gnome
    xwayland-satellite
  ];
}
