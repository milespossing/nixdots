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

        # euler device layer: dual-monitor outputs. Lives at the NixOS level
        # because the niri session package (which bakes this in via NIRI_CONFIG)
        # is installed into the system profile.
        # (nvidia env vars come from the `nvidia` bucket's sessionVariables.)
        desktop = {
          outputs = {
            "DP-2" = {
              mode = "2560x1440@59.950";
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
              focus-at-startup = { };
            };
            "DP-1" = {
              mode = "2560x1440@143.970";
              position = _: {
                props = {
                  x = 2560;
                  y = -8;
                };
              };
              transform = "90";
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

        home-manager.users.miles = {
          my.ai.aider.enable = true;
          my.ai.opencode.enable = true;
          my.ai.copilot-cli.enable = true;
          my.ai.copilot-cli.notifications.enable = true;
        };
      }
    ];
  };
}
