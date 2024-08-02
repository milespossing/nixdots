{ config, lib, pkgs, ... }:
with lib;
let
    cfg = config.services.protonmail-bridge;
in
{
    options = {
        services.protonmail-bridge = {
            enable = mkEnableOption "Enables the bridge";
        };
    };
    
    config = mkIf cfg.enable {
        home.packages = [ pkgs.protonmail-bridge ];
        systemd.user.services.protonmail-bridge = {
          Unit = {
            Description = "Protonmail Bridge";
              After = [ "network.target" ];
            };

            Service = {
              Restart = "always";
              ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --log-level debug --noninteractive --no-window"; # ${cfg.logLevel}" + optionalString (cfg.nonInteractive) " --noninteractive";
            };

            Install = {
              WantedBy = [ "default.target" ];
            };
        };
    };
}
