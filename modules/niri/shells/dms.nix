# Niri + Dank Material Shell
{ pkgs, wlib }:
let
  core = import ../core.nix { inherit pkgs wlib; };
in
core.wrap {
  settings.spawn-at-startup = [
    "${pkgs.dms-shell}/bin/dms"
  ];
}
