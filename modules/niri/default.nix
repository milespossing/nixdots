{
  # Per-device overlay: builds all three shell variants with device-specific
  # output config injected via .wrap on the shell wrappers.
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
    in
    {
      niri-configured = mkShell ./shells/waybar.nix;
      niri-dms = mkShell ./shells/dms.nix;
      niri-noct = mkShell ./shells/noctalia.nix;
    };
}
