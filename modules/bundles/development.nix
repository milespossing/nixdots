{ config, lib, pkgs, inputs, ... }:
with lib;
let cfg = config.bundles.development;
in {
  options.bundles.development = {
    enable = mkEnableOption "Enables gnome";
  };

  config = mkIf cfg.enable {
    mp.virtualization.enable = true;
  };
}

