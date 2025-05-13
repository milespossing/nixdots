{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mp.wsl;
in
{
  options.mp.wsl.enable = lib.mkEnableOption "Enable wsl dots, programs, and services";

  config = mkIf cfg.enable {
    mp.programs.git.gcmCoreIntegration.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.departure-mono
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg

      wslu
    ];

    fonts.fontconfig.enable = true;
  };
}
