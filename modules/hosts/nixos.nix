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
      ./nixos-wsl/_hardware.nix
      {
        networking.hostName = "nixos";
        programs.nh.flake = "/home/miles/.config/nixos";
        system.stateVersion = "26.05";

        home-manager.users.miles = {
          my.ai.aider.enable = true;
          my.ai.opencode.enable = true;
          my.ai.copilot-cli.enable = true;
          skills.extra = [
            "figma-to-spec"
            "fluent-ui-v9"
          ];
        };
      }
    ];
  };
}
