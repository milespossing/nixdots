{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.sdev.clojure;
in
{
  options.sdev.clojure.enable = mkEnableOption "Enables clojure";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      clojure
    ];
  };
}
