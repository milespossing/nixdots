{ lib, ... }:
{
  options = {
    my.username = lib.mkOption {
      type = lib.types.str;
      default = "miles";
      description = "The username of the primary user.";
    };
  };
}
