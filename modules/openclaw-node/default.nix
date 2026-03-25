# OpenClaw node host — connects to a remote OpenClaw gateway and exposes
# system.run / system.which so the agent can execute commands on this machine.
#
# Secrets (gateway host, port, token) are managed via sops-nix and sourced
# from an EnvironmentFile at service start.
#
# Prerequisites: the host must import sops-nix.nixosModules.sops and have
# sops.age.keyFile (or equivalent) configured.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.openclaw-node;
in
{
  options.my.openclaw-node = {
    enable = lib.mkEnableOption "OpenClaw node host (connects to a remote gateway)";

    displayName = lib.mkOption {
      type = lib.types.str;
      description = "Display name shown in `openclaw nodes status` on the gateway.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.my.username;
      description = "User to run the node service as.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.openclaw;
      defaultText = lib.literalExpression "pkgs.openclaw";
      description = "OpenClaw package providing the `openclaw` binary.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.path;
      default = ./gateway.enc.yaml;
      description = ''
        Sops-encrypted YAML file containing the keys:
          openclaw-gateway-host, openclaw-gateway-port, openclaw-gateway-token
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments passed to `openclaw node run`.";
      example = [
        "--tls"
        "--tls-fingerprint"
        "abc123"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # -- sops secrets --------------------------------------------------------
    sops.secrets.openclaw-gateway-host = {
      sopsFile = cfg.sopsFile;
    };
    sops.secrets.openclaw-gateway-port = {
      sopsFile = cfg.sopsFile;
    };
    sops.secrets.openclaw-gateway-token = {
      sopsFile = cfg.sopsFile;
    };

    # Template sourced as EnvironmentFile by the service.
    sops.templates."openclaw-node-env" = {
      content = ''
        OPENCLAW_NODE_GATEWAY_HOST=${config.sops.placeholder."openclaw-gateway-host"}
        OPENCLAW_NODE_GATEWAY_PORT=${config.sops.placeholder."openclaw-gateway-port"}
        OPENCLAW_GATEWAY_TOKEN=${config.sops.placeholder."openclaw-gateway-token"}
      '';
      owner = cfg.user;
    };

    # -- package on PATH -----------------------------------------------------
    environment.systemPackages = [ cfg.package ];

    # -- systemd service -----------------------------------------------------
    systemd.services.openclaw-node = {
      description = "OpenClaw node host (${cfg.displayName})";
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/openclaw"
            "node"
            "run"
            "--host"
            "\${OPENCLAW_NODE_GATEWAY_HOST}"
            "--port"
            "\${OPENCLAW_NODE_GATEWAY_PORT}"
            "--display-name"
            ''"${cfg.displayName}"''
          ]
          ++ cfg.extraArgs
        );
        EnvironmentFile = config.sops.templates."openclaw-node-env".path;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
