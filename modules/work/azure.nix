{ inputs, ... }:
{
  flake.modules.nixos.work =
    { pkgs, ... }:
    {
      # azure-cli pinned via nixpkgs-master overlay (fix for #493712).
      nixpkgs.overlays = [
        (import ../../overlays/azure-cli-fix.nix { nixpkgs-master = inputs.nixpkgs-master; })
      ];
      environment.systemPackages = [
        (pkgs.azure-cli.withExtensions [
          pkgs.azure-cli.extensions.azure-devops
          pkgs.azure-cli.extensions.kusto
        ])
      ];
    };
}
