{
  # Create a wayland session entry from a wrapped niri package.
  mkSession = import ./mkSession.nix;

  # Per-device overlay: builds all three shell variants with device-specific
  # output config and proper session desktop entries for the greeter.
  mkOverlays =
    wlib:
    { deviceModule }:
    final: prev:
    let
      mkShell =
        shellFile:
        let
          shell = import shellFile {
            pkgs = final;
            inherit wlib;
          };
        in
        shell.wrap deviceModule;

      mkSession = import ./mkSession.nix;
    in
    {
      niri-configured = mkSession {
        pkgs = final;
        wrapped = mkShell ./shells/waybar.nix;
        name = "niri-configured";
        displayName = "Niri";
      };
      niri-dms = mkSession {
        pkgs = final;
        wrapped = mkShell ./shells/dms.nix;
        name = "niri-dms";
        displayName = "Niri DMS";
      };
      niri-noct = mkSession {
        pkgs = final;
        wrapped = mkShell ./shells/noctalia.nix;
        name = "niri-noct";
        displayName = "Niri Noctalia";
      };
    };
}
