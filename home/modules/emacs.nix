{ lib, pkgs, config, ... }:
with lib;
let cfg = config.programs.emacs;
in {
  options.programs.emacs = {
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
