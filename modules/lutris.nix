{ config, lib, pkgs, ... }:
with lib;
let cfg = config.programs.lutris;
in {
  options.programs.lutris = {
    enable = mkEnableOption "Enables Lutris";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
    ];
  };
}
    
