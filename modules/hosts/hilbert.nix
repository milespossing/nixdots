{ config, mkHost, ... }:
{
  # WSL work host.
  flake.nixosConfigurations.hilbert = mkHost {
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
        networking.hostName = "hilbert";
        programs.nh.flake = "/home/${config.username}/.config/nixdots";
        system.stateVersion = "26.05";
      }
    ];
  };
}
