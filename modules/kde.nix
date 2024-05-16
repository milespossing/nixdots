{ config, lib, ... }:
with lib;
let cfg = config.mp.wm.kde;
in {
  options.mp.wm.kde = {
    enable = mkEnableOption "Enables kde";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
  };
}
