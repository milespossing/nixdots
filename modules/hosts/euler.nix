{ mkHost, ... }:
{
  flake.nixosConfigurations.euler = mkHost {
    buckets = [
      "base"
      "hardware"
      "nvidia"
      "i3"
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
        };
      }
    ];
  };
}
