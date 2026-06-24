{ inputs, ... }:
{
  # WSL GPG key + password-store bootstrap. The signing key is delivered via
  # sops and imported on activation; pass is initialised against it.
  flake.modules.homeManager.wsl =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        defaultSymlinkPath = "/run/user/1000/secrets";
        defaultSecretsMountPoint = "/run/user/1000/secrets.d";
        secrets.gpg_key.sopsFile = ./gpg-key.enc.yaml;
      };

      # sops-nix's upstream activation does `systemctl restart --user sops-nix`,
      # but that user unit is only linked later in activation (linkGeneration /
      # reloadSystemd). On a host's first ever switch the unit doesn't exist yet,
      # so the restart fails with "Unit sops-nix.service not found" and aborts the
      # whole Home-Manager activation (exit 5) — which is what breaks switching on
      # a fresh WSL host. Install the secrets synchronously instead (the exact
      # thing the unit's ExecStart does), which has no user-session dependency and
      # runs before importGpgKey. The WantedBy=default.target service still handles
      # re-decryption on login. Skip on boot activation, when the runtime dir
      # (and thus the secrets symlink target) doesn't exist yet.
      home.activation.sops-nix = lib.mkForce ''
        if [ -d "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" ]; then
          ${lib.concatStringsSep " " (lib.toList config.systemd.user.services.sops-nix.Service.ExecStart)} \
            || echo "sops-nix: secret activation failed; will retry via systemd (default.target)"
        else
          echo "Runtime dir not present (boot activation); sops-nix loads via default.target."
        fi
      '';

      home.activation.importGpgKey = lib.hm.dag.entryAfter [ "sops-nix" ] ''
        if [ -f "${config.sops.secrets.gpg_key.path}" ]; then
          ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets.gpg_key.path} 2>/dev/null || true
          KEY_FPR=$(${pkgs.gnupg}/bin/gpg --list-keys --with-colons 2>/dev/null | grep '^fpr' | head -1 | cut -d: -f10)
          if [ -n "$KEY_FPR" ]; then
            echo "$KEY_FPR:6:" | ${pkgs.gnupg}/bin/gpg --batch --import-ownertrust 2>/dev/null || true
          fi
        fi
      '';

      home.activation.initPasswordStore = lib.hm.dag.entryAfter [ "importGpgKey" ] ''
        if [ ! -f "$HOME/.password-store/.gpg-id" ]; then
          KEY_ID=$(${pkgs.gnupg}/bin/gpg --list-secret-keys --with-colons 2>/dev/null | grep '^sec' | head -1 | cut -d: -f5)
          if [ -n "$KEY_ID" ]; then
            ${pkgs.pass}/bin/pass init "$KEY_ID"
          fi
        fi
      '';
    };
}
