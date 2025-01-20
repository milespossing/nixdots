{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mp.virtualization;
in
{
  options.mp.virtualization = {
    enable = mkEnableOption "Enables gnome";
  };

  # TODO: Remove this once virtualization can work again
  config = mkIf (cfg.enable && false) {
    environment.systemPackages = with pkgs; [
      spice
      spice-gtk
      swtpm
    ];

    virtualisation = {
      docker.enable = true;
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_full;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [
              (pkgs.OVMF.override {
                secureBoot = true;
                tpmSupport = true;
              }).fd
            ];
          };
        };
      };
      spiceUSBRedirection.enable = true;
    };

    programs.virt-manager.enable = true;

    services.spice-vdagentd.enable = true;

    # TODO: Going to want to make this respond to the default user name
    users.users.miles.extraGroups = [ "docker" ];
  };
}
