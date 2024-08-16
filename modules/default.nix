{ ... }:
{
  imports = [
    ./bundles
    ./gnome.nix
    ./hyprland.nix
    ./kde.nix
    ./lutris.nix
    ./virtualization.nix
    ./wine.nix
  ];


  # misc.
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };
}
