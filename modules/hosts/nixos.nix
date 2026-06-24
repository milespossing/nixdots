{ mkHost, ... }:
{
  # WSL work host.
  flake.nixosConfigurations.nixos = mkHost {
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
        networking.hostName = "nixos";
        programs.nh.flake = "/home/miles/.config/nixos";
        system.stateVersion = "26.05";
      }
    ];
  };
}
