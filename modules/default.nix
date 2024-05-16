{ ... }:
{
  imports = [
    ./hyprland.nix
    ./kde.nix
    ./gnome.nix
    ./steam.nix
    ./virtualization.nix
    ./bundles
  ];


  # misc.
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };
}
