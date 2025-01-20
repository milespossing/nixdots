{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.sdev.racket;
in
{
  options.sdev.racket = {
    enable = mkEnableOption "Enables racket";
    full = mkEnableOption "Enables DrRacket";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (if cfg.full then racket else racket-minimal)
    ];
  };
}
