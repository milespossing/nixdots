{ pkgs, lib, ... }:
{
  imports = [
    ./modules
    ./basic.nix
    ./user-space.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
      "tetrio-desktop"
    ];
}
