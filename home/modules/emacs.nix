{ lib, pkgs, config, ... }:
with lib;
let cfg = config.programs.emacs;
in {
  config = mkIf cfg.enable {
    home.file.".config/emacs" = {
      source = ../dots/emacs;
      recursive = true;
    };
  };
}
