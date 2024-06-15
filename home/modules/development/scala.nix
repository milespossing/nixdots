{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.sdev.scala;
in {
  options.mp.sdev.scala = {
    enable = mkEnableOption "Enables scala";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      scala
      sbt
    ];
  };
}
