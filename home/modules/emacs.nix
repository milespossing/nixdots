{ lib, pkgs, config, ... }:
with lib;
let cfg = config.mp.programs.emacs;
in {
  options.mp.programs.emacs = {
    enable = mkEnableOption "Enables emacs";
    package = mkPackageOption pkgs "emacs" {
      default = ["emacs29"];
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      cfg.package
    ];

    home.file.".config/emacs" = {
      source = ../dots/emacs;
      recursive = true;
    };
  };
}
