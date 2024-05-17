{ pkgs, config, lib, ... }:
{
  imports = [
    ../../home/basic.nix
    ../../home/user-space.nix
  ];

  home.packages = with pkgs; [
    zip
  ]p

  home.username = "miles";
  home.homeDirectory = "/Users/miles";

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
