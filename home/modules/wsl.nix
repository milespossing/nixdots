{ config, lib, ... }:
with lib;
let cfg = config.mp.wsl;
in {
  options.mp.wsl.enable = lib.mkEnableOption "Enable user-space dots, programs, and services";

  config = mkIf cfg.enable {
    mp.programs.git.gcmCoreIntegration.enable = true;
  };
}
