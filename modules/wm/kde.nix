{ pkgs, ... }:
{
  programs.kdeconnect.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.desktopManager.plasma6.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.packages = with pkgs; [ gnome-keyring ];

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kwallet
    kdePackages.kwalletmanager
    libsecret
    seahorse
  ];
}
