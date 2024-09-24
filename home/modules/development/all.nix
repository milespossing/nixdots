{ config, lib, ... }:
with lib;
let cfg = config.sdev;
in {
  options.sdev.all = mkEnableOption "Enables everything";

  config = mkIf cfg.all {
    sdev.clojure.enable = true;
    mp.sdev.dotnet.enable = true;
    mp.sdev.scala.enable = true;
    sdev.racket.enable = true;
  };
}
