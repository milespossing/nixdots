{ config, lib, pkgs, ... }:
with lib;
let cfg = config.sdev.racket;
in {
  options.sdev.racket.enable = mkEnableOption "Enables racket";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      racket
    ];
  };
}
