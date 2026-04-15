# Niri + Dank Material Shell (no bar)
{ pkgs, wlib }:
let
  core = import ../core.nix { inherit pkgs wlib; };
in
core.wrap { }
