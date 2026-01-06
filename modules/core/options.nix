{ lib, ... }:
{
  options = {
    my.username = lib.mkOption {
      type = lib.types.str;
      default = "miles";
      description = "The username of the primary user.";
    };
    my.flakePath = lib.mkOption {
      type = lib.types.path;
      default = "/home/miles/src/nixdots";
      description = "The path to the user's Nix flake.";
    };
  };
}
