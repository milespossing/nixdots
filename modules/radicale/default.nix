# Radicale CalDAV/CardDAV server — lightweight, file-based calendar & contacts.
#
# Auth via htpasswd (bcrypt) with the password file managed by sops-nix.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.radicale;
in
{
  options.my.radicale = {
    enable = lib.mkEnableOption "Radicale CalDAV/CardDAV server";

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address Radicale listens on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5232;
      description = "Port Radicale listens on.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ./radicale-htpasswd.enc.yaml;
      description = ''
        Sops-encrypted YAML file containing the key:
          radicale-htpasswd  — htpasswd-format string (bcrypt)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # -- sops secret ---------------------------------------------------------
    sops.secrets.radicale-htpasswd = {
      sopsFile = cfg.sopsFile;
      owner = "radicale";
      group = "radicale";
    };

    # -- Radicale service ----------------------------------------------------
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "${cfg.host}:${toString cfg.port}" ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets.radicale-htpasswd.path;
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
        rights = {
          type = "owner_only";
        };
      };
    };
  };
}
