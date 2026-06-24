{ mkHost, ... }:
{
  flake.nixosConfigurations.euler = mkHost {
    buckets = [
      "base"
      "hardware"
      "nvidia"
      "niri"
      "gaming"
      "printing3d"
      "media-production"
      "qmk"
      "dev"
      "ai"
      "skills"
      "syncthing"
      "virt"
      "wine"
      "mounts"
      "wireguard"
      "samba"
    ];
    modules = [
      ./euler/_hardware.nix
      {
        networking.hostName = "euler";
        networking.firewall.allowedTCPPorts = [ 8080 ];

        # Never sleep (workstation/server).
        systemd.targets.sleep.enable = false;
        systemd.targets.suspend.enable = false;
        systemd.targets.hibernate.enable = false;
        systemd.targets.hybrid-sleep.enable = false;

        system.stateVersion = "23.11";

        home-manager.users.miles = {
          my.ai.aider.enable = true;
          my.ai.opencode.enable = true;
          my.ai.copilot-cli.enable = true;
          my.ai.copilot-cli.notifications.enable = true;

          # euler device layer: dual-monitor outputs + workspace pinning.
          # (nvidia env vars come from the `nvidia` bucket's sessionVariables.)
          programs.niri.settings = {
            outputs = {
              "DP-2" = {
                mode = {
                  width = 2560;
                  height = 1440;
                  refresh = 59.950;
                };
                position = {
                  x = 0;
                  y = 0;
                };
              };
              "DP-1" = {
                mode = {
                  width = 2560;
                  height = 1440;
                  refresh = 143.970;
                };
                position = {
                  x = 2560;
                  y = -8;
                };
                transform.rotation = 90;
              };
            };
            # Bind all named workspaces to the primary monitor.
            workspaces = {
              "1-main".open-on-output = "DP-2";
              "2-browser".open-on-output = "DP-2";
              "3-dev".open-on-output = "DP-2";
              "4-chat".open-on-output = "DP-2";
              "5-media".open-on-output = "DP-2";
            };
          };
        };
      }
    ];
  };
}
