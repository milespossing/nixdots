{ pkgs, ... }:
{
  imports = [
    ./development
    ./emacs.nix
    ./eww
    ./git.nix
    ./hyprland
    ./protonmail-bridge.nix
    ./rofi.nix
    ./shells
    ./tmux.nix
    ./user-space.nix
    ./wsl.nix
  ];
}
