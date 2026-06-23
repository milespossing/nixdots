{ inputs, ... }:
{
  # Third-party + local overlays applied to every host's nixpkgs.
  flake.modules.nixos.base.nixpkgs.overlays = [
    (import ../../overlays/zellij-plugins.nix)
    (import ../../overlays/kulala-nvim.nix)
  ];
}
