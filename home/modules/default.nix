{ pkgs, ... }:
{
  imports = [
    ./development
    ./emacs.nix
    ./git.nix
    ./nvim
    ./protonmail-bridge.nix
    ./shells
    ./tmux.nix
    ./user-space.nix
    ./wsl.nix
  ];
}
