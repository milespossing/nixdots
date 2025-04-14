{ pkgs, ... }:
with pkgs;
{
  environment.systemPackages = [
    gnome-network-displays
  ];
}
