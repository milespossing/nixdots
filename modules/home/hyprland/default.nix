# TODO: Still need to see if this works
{ config, pkgs, inputs, ... }: 
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };

  programs.waybar.enable = true;

  programs.nm-applet.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "hyprland";
    };
    # misc.
    xkb.layout = "us";
    xkb.variant = "";
  };

  environment.systemPackages = with pkgs; [
	  swww
	  nwg-drawer
	  swayosd
    wl-clipboard
    wlogout
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
