# Wrapped DMS (Dank Material Shell) — bakes in the `run` subcommand
# so spawning the wrapper starts the shell without extra args.
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
  }
]
