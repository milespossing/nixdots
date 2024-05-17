{ config, lib, pkgs, inputs, ... }:
with lib;
let cfg = config.mp.virtualization;
in {
  options.mp.virtualization = {
    enable = mkEnableOption "Enables gnome";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    # TODO: Going to want to make this respond to the default user name
    users.users.miles.extraGroups = [ "docker" ];
  };
}

