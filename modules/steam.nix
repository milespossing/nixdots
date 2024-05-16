{ config, lib, pkgs, inputs, ... }:
with lib;
let cfg = config.mp.steam;
in {
  options.mp.steam = {
    enable = mkEnableOption "Enables gnome";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
    };
  };
}
