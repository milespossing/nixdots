{ inputs, config, ... }:
{
  imports = [ inputs.nix-index-database.nixosModules.default ];

  programs.nix-index-database.comma.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = config.my.flakePath;
  };
}
