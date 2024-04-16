{ config, lib, pkgs, ... }:
with lib;
let cfg = config.mp.sdev.dotnet;
in {
  options.mp.sdev.dotnet = {
    enable = mkEnableOption "Enables dotnet";
    extraPackages = mkOption {
      type = types.listOf types.package;
      description = "Extra dotnet versions to install";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dotnet-sdk
    ] ++ cfg.extraPackages;
  };
}