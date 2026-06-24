{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.flake.modules;
  user = "miles";

  # Buckets that have a homeManager side, given a list of bucket names.
  hmBuckets =
    buckets:
    lib.attrValues (lib.getAttrs (lib.filter (b: cfg.homeManager ? ${b}) buckets) cfg.homeManager);

  nixosBuckets =
    buckets: lib.attrValues (lib.getAttrs (lib.filter (b: cfg.nixos ? ${b}) buckets) cfg.nixos);

  # mkHost: a host opts into a list of bucket names. Both the nixos.<bucket>
  # and homeManager.<bucket> modules are pulled in (the latter onto the user's
  # home-manager). Bucket-to-bucket `imports` handle layering (e.g. i3 → x11 → core).
  mkHost =
    {
      system ? "x86_64-linux",
      buckets,
      modules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules =
        nixosBuckets ([ "home-manager" ] ++ buckets)
        ++ [
          { nixpkgs.hostPlatform = lib.mkDefault system; }
          { home-manager.users.${user}.imports = hmBuckets buckets; }
        ]
        ++ modules;
    };
in
{
  _module.args.mkHost = mkHost;

  # Glue: pull home-manager into NixOS. Hosts always get this via mkHost.
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.${user}.home.stateVersion = "23.11";
    };
  };
}
