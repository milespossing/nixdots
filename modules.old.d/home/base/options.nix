{ lib, ... }:
{
  options.my = {
    alias.name = lib.mkOption {
      type = lib.types.str;
      default = "Miles Possing";
    };
    alias.email = lib.mkOption {
      type = lib.types.str;
      default = "mp-complete@pm.me";
    };
  };
}
