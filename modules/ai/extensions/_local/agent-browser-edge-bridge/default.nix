{
  runCommand,
  lib,
}:
# agent-browser-edge-bridge — pi extension, built locally (not from npm).
#
# Produces a derivation whose output is a pi-package directory layout
# (the same shape `mkPiExtensionFromNpm` produces for upstream packages):
#
#   $out/package.json
#   $out/src/index.ts
#   $out/scripts/bootstrap.sh
#   $out/scripts/cdp_forwarder.py
#   $out/README.md
#
# The pi wrapper picks it up via `--extension $out`. Pi reads the `pi`
# manifest in `package.json` to learn which TS file to load.
let
  pname = "agent-browser-edge-bridge";
  version = "0.1.0";

  # Filter the source so default.nix and editor cruft don't end up in
  # the store output. Keeps the derivation hash stable when only
  # Nix-side wiring (not the extension itself) changes.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./package.json
      ./README.md
      ./src
      ./scripts
    ];
  };
in
runCommand "pi-ext-${pname}-${version}"
  {
    inherit src;
    meta = {
      description = "Pi extension: route agent_browser tool calls through a Windows-Edge CDP bridge from WSL.";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
    passthru = {
      inherit pname version;
      piExtension = true;
    };
  }
  ''
    mkdir -p $out
    cp -r $src/. $out/
    chmod +x $out/scripts/bootstrap.sh
  ''
