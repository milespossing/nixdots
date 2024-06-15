{ config, lib, ... }:
with lib;
let cfg = config.mp.wm.kde;
in {
  options.mp.wm.kde = {
    enable = mkEnableOption "Enables kde";
    version6 = mkEnableOption "Enables version6";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = mkIf (cfg.version6 != true) true;
    services.desktopManager.plasma6.enable = mkIf cfg.version6 true;
  };
}
