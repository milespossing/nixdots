{ pkgs, ... }:
{
  imports = [
    ./dotnet.nix
    ./emacs.nix
    ./eww
    ./git.nix
    ./hyprland
    ./rofi.nix
    ./shells
    ./tmux.nix
    ./user-space.nix
    ./wsl.nix
  ];
}
