{ config, lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e57deb0b-7e11-43b4-80d9-3e8e6f6d6dc9";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4484-F17A";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/gamedisk" = {
    device = "/dev/disk/by-uuid/645C234A4278F1E6";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "user"
      "exec"
      "uid=1000"
      "gid=100"
      "umask=000"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
