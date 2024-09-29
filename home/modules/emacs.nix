{ lib, pkgs, config, ... }:
with lib;
let cfg = config.mp.programs.emacs;
in {
  options.mp.programs.emacs = {
    enable = mkEnableOption "Enables emacs";
    package = mkPackageOption pkgs "emacs" {
      default = ["emacs29"];
    };
    useDoom = mkEnableOption "Enables doom rather than personal emacs";
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.file.".config/emacs" = {
      source = if cfg.useDoom then ../dots/doomemacs else ../dots/emacs;
      recursive = true;
    };
  };
}
