{ inputs, ... }:
{
  # sops-nix wiring. Per-feature secret declarations live next to their feature
  # (network/mounts.nix, network/wireguard.nix, ai/secrets.nix). This only sets
  # the defaults: where the age key lives.
  flake.modules.nixos.base = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.age.keyFile = "/etc/nixos/keys.txt";
  };
}
