{ lib }:
# Aggregator for nix-wrapper-modules-based package wrappers.
#
# Each subdirectory must export `{ package; overlay; }` where
#   - `package` is a function `{ pkgs, wlib, basePackage ? ... }: drv`
#     (callable from `flake.packages` or anywhere downstream)
#   - `overlay` is a function `wlib: final: prev: { <name> = drv; }`
#     suitable for `nixpkgs.overlays`.
#
# To register a new wrapper: drop a directory in here that follows the
# pattern from `pi/` (or the existing `modules/{yazi,tmux,kitty}/`).
# No edits to this file required.
let
  dir = builtins.readDir ./.;

  # Treat any subdir with a default.nix as a wrapper. Skip files
  # (e.g. this default.nix), README.md, etc.
  isWrapperDir =
    name: dir.${name} == "directory" && builtins.pathExists (./. + "/${name}/default.nix");

  wrapperNames = builtins.filter isWrapperDir (builtins.attrNames dir);

  wrappers = lib.genAttrs wrapperNames (n: import (./. + "/${n}"));
in
{
  # Direct access if you ever need a single wrapper's package or
  # overlay in isolation (e.g. for `flake.packages.<system>.pi`).
  inherit wrappers;

  # Combined overlay -- drop into `nixpkgs.overlays`. Uses
  # composeManyExtensions so wrappers can layer on each other's
  # outputs via `final` if that ever becomes relevant.
  overlay = wlib: lib.composeManyExtensions (map (w: w.overlay wlib) (lib.attrValues wrappers));
}
