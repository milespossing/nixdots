{ inputs, ... }:
let
  wlib = inputs.nix-wrapper-modules.lib;
  wrappers = import ../../wrappers { inherit (inputs.nixpkgs) lib; };
in
{
  # nix-wrapper-modules packages (kitty, tmux, yazi, rofi, dunst, …) exposed as
  # overlays — the single source of truth for their config (decision #2).
  flake.modules.nixos.base.nixpkgs.overlays = [
    (import ../../overlays/pi-coding-agent.nix)
    (import ../../overlays/pi-extensions)
    (wrappers.overlay wlib)
  ];
}
