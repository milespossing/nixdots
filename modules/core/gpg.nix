{ pkgs, ... }:
{
  services.pcscd.enable = true;
  services.passSecretService = {
    enable = true;
    package = pkgs.pass-secret-service;
  };

  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gtk2;
      enableSSHSupport = true;
      enableBrowserSocket = true;
    };
  };
}
