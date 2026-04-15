# Wrapped DMS (Dank Material Shell) — bakes in the `run` subcommand
# and bundles quickshell (qs) in PATH so the Go binary can find it.
{
  pkgs,
  wlib,
  basePackage ? pkgs.dms-shell,
}:
wlib.evalPackage [
  wlib.modules.default
  {
    inherit pkgs;
    package = basePackage;
    addFlag = [ "run" ];
    extraPackages = [ pkgs.dms-quickshell ];
  }
]
