{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.sops-nix.nixosModules.sops
  ];

  wsl = {
    enable = true;
    defaultUser = config.my.username;
    wslConf.automount.options = "metadata,umask=22,fmask=11";
  };

  # Allow running unpatched dynamically-linked binaries (e.g. .NET tools
  # installed via corporate installers like PathInstaller/agency).
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    icu
    zlib
    curl
  ];

  # Secret Service provider backed by pass/GPG (replaces gnome-keyring)
  services.dbus.packages = [ pkgs.pass-secret-service ];
  systemd.user.services.pass-secret-service = {
    description = "Pass-backed Secret Service";
    serviceConfig = {
      ExecStart = "${pkgs.pass-secret-service}/bin/pass_secret_service";
      BusName = "org.freedesktop.secrets";
    };
  };
  environment.systemPackages = [ pkgs.libsecret ];
}
