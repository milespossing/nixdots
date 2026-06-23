{ inputs, config, ... }:
{
  flake.modules.nixos.wsl =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-wsl.nixosModules.wsl ];

      wsl = {
        enable = true;
        defaultUser = config.username;
        wslConf.automount.options = "metadata,umask=22,fmask=11";
      };

      # Run unpatched dynamically-linked binaries (corporate .NET tools).
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        openssl
        icu
        zlib
        curl
      ];

      # Secret Service backed by pass/GPG (replaces gnome-keyring on WSL).
      services.dbus.packages = [ pkgs.pass-secret-service ];
      systemd.user.services.pass-secret-service = {
        description = "Pass-backed Secret Service";
        serviceConfig = {
          ExecStart = "${pkgs.pass-secret-service}/bin/pass_secret_service";
          BusName = "org.freedesktop.secrets";
        };
      };
      environment.systemPackages = with pkgs; [
        libsecret
        zathura
        pi-coding-agent-wsl # WSL/work pi (base + WSL-specific extensions)
      ];
    };

  flake.modules.homeManager.wsl =
    { pkgs, ... }:
    {
      programs.gpg.enable = true;
      programs.password-store.enable = true;
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        wsl-open
        xdg-utils
      ];
      shell.initExtra = "export WSL=1";
    };
}
