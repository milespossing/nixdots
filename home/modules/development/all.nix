{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.sdev;
in {
  options.mp.sdev.all = mkEnableOption "Enables everything";

  config = mkIf cfg.all {
    mp.sdev.dotnet.enable = true;
    mp.sdev.scala.enable = true;
  };
}
