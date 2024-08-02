{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.wsl;
in {
  options.mp.wsl.enable = lib.mkEnableOption "Enable wsl dots, programs, and services";

  config = mkIf cfg.enable {
    mp.programs.git.gcmCoreIntegration.enable = true;

    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Meslo" ]; })
    ];

    fonts.fontconfig.enable = true;
  };
}
