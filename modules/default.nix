{ ... }:
{
  imports = [
    ./bundles
    ./fonts.nix
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
