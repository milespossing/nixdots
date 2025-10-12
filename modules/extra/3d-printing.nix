{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    freecad
    # FIXME: bambu-studio doesn't build correctly right now
    # bambu-studio
    orca-slicer
  ];
}
