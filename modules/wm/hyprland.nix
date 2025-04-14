{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../extra/zen-browser.nix
  ];

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  environment.systemPackages = with pkgs; [
    hyprcursor
    hypridle
    hyprlock
    # not sure I need this
    hyprpolkitagent
    hyprsunset
    libnotify
    slurp
    swaynotificationcenter
    inputs.swww.packages.${pkgs.system}.swww
    waybar
    wl-clipboard
    wlogout
    # Hardward controls
    bluetui
    brightnessctl
  ];

  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  services.xserver = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      # oh my god
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # programs.regreet.enable = true;

  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };
}
