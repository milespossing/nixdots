{
  lib,
  pkgs,
  ...
}:
with lib;
{
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    swtpm
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  services.spice-vdagentd.enable = true;

  # TODO: Going to want to make this respond to the default user name
  users.users.miles.extraGroups = [
    "libvirtd"
  ];
}
