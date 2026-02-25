{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    secrets.gpg_key = {
      sopsFile = ./gpg-key.enc.yaml;
    };
  };

  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "sopsNix" ] ''
    ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets.gpg_key.path} 2>/dev/null || true
  '';

  home.activation.initPasswordStore = lib.hm.dag.entryAfter [ "importGpgKey" ] ''
    if [ ! -f "$HOME/.password-store/.gpg-id" ]; then
      KEY_ID=$(${pkgs.gnupg}/bin/gpg --list-secret-keys --with-colons 2>/dev/null | grep '^sec' | head -1 | cut -d: -f5)
      if [ -n "$KEY_ID" ]; then
        ${pkgs.pass}/bin/pass init "$KEY_ID"
      fi
    fi
  '';
}
