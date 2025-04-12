# Sets the machine up for basic work with msft This seems not to work
# currently, so I should be sure to leave it off. It would seem that the main
# error mode here is that portal doesn't work particularly well on anything but
# ubuntu, and needs gnome??? At anyrate, this module is defunct.

{ pkgs, ... }:
with pkgs;
{
  environment.systemPackages = [
    microsoft-edge
    intune-portal
  ];
}
