{ pkgs, lib, ... }:
{
  imports = [
    ./modules
    ./basic.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "vivaldi"
      "spotify"
      "tetrio-desktop"
    ];
}
