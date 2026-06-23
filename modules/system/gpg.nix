{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      services.pcscd.enable = true;
      environment.systemPackages = [ pkgs.pass ];
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        enableSSHSupport = true;
        enableBrowserSocket = true;
      };
    };
}
