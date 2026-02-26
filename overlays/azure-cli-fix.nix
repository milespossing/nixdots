# Temporary overlay: pull azure-cli from pinned nixpkgs master
# Fixes: https://github.com/NixOS/nixpkgs/issues/493712
# Remove once nixos-unstable includes azure-cli >= 2.82.0
{ nixpkgs-master }:
final: prev:
let
  pkgs-master = import nixpkgs-master { inherit (prev) system; };
in
{
  inherit (pkgs-master) azure-cli;
}
