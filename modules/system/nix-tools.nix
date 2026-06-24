{ inputs, lib, ... }:
{
  flake.modules.nixos.base = {
    imports = [ inputs.nix-index-database.nixosModules.default ];
    programs.nix-index-database.comma.enable = true;
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = lib.mkDefault "/home/miles/src/nixdots";
    };
  };
}
