{ config, ... }:
{
  # kitty is wrapped by its nix-wrapper-module (wrappers/kitty); install the
  # wrapped package from the flake.wrappers registry.
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ (config.flake.wrappers.kitty.wrap { inherit pkgs; }) ];
    };
}
