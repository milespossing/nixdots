# Niri + Waybar shell wrapper
{ pkgs, wlib }:
let
  core = import ../core.nix { inherit pkgs wlib; };
in
core.wrap {
  settings.spawn-at-startup = [
    "${pkgs.waybar}/bin/waybar"
  ];
}
