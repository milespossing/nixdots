{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mp.sdev.dotnet;
in
{
  options.mp.sdev.dotnet = {
    enable = mkEnableOption "Enables dotnet";
    version = mkOption {
      type = types.package;
      description = "Extra dotnet versions to install";
      default = pkgs.dotnet-sdk;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.version
    ];
  };
}
