{
  # Create a wayland session entry from a wrapped niri package.
  mkSession = import ./mkSession.nix;

  # Per-device overlay: builds a single Niri + Noctalia session with
  # device-specific output config and a proper session desktop entry for the greeter.
  mkOverlays =
    wlib:
    { deviceModule }:
    final: prev:
    let
      shell = import ./shells/noctalia.nix {
        pkgs = final;
        inherit wlib;
      };
      wrapped = shell.wrap deviceModule;
      mkSession = import ./mkSession.nix;
    in
    {
      niri-configured = mkSession {
        pkgs = final;
        inherit wrapped;
        name = "niri-configured";
        displayName = "Niri";
      };
    };
}
