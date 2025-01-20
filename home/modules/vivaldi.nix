{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.vivaldi;
  vivaldi-package =
    if cfg.useWayland then
      (pkgs.vivaldi.overrideAttrs (oldAttrs: {
        dontWrapQtApps = false;
        dontPatchELF = true;
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
      }))
    else
      pkgs.vivaldi;
in
{
  options.programs.vivaldi = {
    enable = mkEnableOption "Enables vivaldi browser";
    useWayland = mkEnableOption "Enables wayland";
  };

  config = mkIf cfg.enable {
    home.packages = [ vivaldi-package ];
  };
}
