{ ... }: {
  imports = [
    ./development
    ./emacs.nix
    ./git.nix
    ./navi
    ./protonmail-bridge.nix
    ./shells.nix
    ./tmux.nix
    ./user-space.nix
  ];
}
