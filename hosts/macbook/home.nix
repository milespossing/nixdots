{ config, pkgs, outputs, inputs, ... }:
{
  imports = [
    # ../../home/basic.nix
  ];

  home.username = "miles";
  home.homeDirectory = "/Users/miles";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
