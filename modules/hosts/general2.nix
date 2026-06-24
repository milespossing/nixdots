{ config, mkHost, ... }:
{
  flake.nixosConfigurations.general2 = mkHost {
    buckets = [
      "base"
      "dev"
      "ai"
      "skills"
      "syncthing"
      "work"
      "wsl"
    ];
    modules = [
      {
        networking.hostName = "general2";
        programs.nh.flake = "/home/${config.username}/.config/nixdots";
        system.stateVersion = "26.05";
      }
    ];
  };
}
