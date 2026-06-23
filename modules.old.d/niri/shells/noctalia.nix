# Niri + Noctalia shell wrapper
{ pkgs, wlib }:
let
  core = import ../core.nix { inherit pkgs wlib; };
in
core.wrap {
  settings.spawn-at-startup = [
    "${pkgs.noctalia-shell}/bin/noctalia-shell"
  ];
}
