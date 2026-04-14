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

  # Build the exec-approvals.json structure from Nix options.
  execApprovalsJson = {
    version = 1;
    defaults = {
      inherit (cfg.exec)
        security
        ask
        askFallback
        autoAllowSkills
        ;
    };
  }
  // lib.optionalAttrs (cfg.exec.agents != { }) {
    agents = lib.mapAttrs (
      _name: agentCfg:
      {
        inherit (agentCfg)
          security
          ask
          askFallback
          autoAllowSkills
          ;
      }
      // lib.optionalAttrs (agentCfg.allowlist != [ ]) {
        allowlist = map (entry: {
          inherit (entry) pattern;
        }) agentCfg.allowlist;
      }
    ) cfg.exec.agents;
  };

  # Submodule for per-agent exec approval settings.
  agentExecModule = lib.types.submodule {
    options = {
      security = lib.mkOption {
        type = lib.types.enum [
          "deny"
          "allowlist"
          "full"
        ];
        default = cfg.exec.security;
        description = "Exec security mode for this agent.";
      };

      ask = lib.mkOption {
        type = lib.types.enum [
          "off"
          "on-miss"
          "always"
        ];
        default = cfg.exec.ask;
        description = "Approval prompt behaviour for this agent.";
      };

      askFallback = lib.mkOption {
        type = lib.types.enum [
          "deny"
          "allowlist"
          "full"
        ];
        default = cfg.exec.askFallback;
        description = "Fallback when no approval UI is available for this agent.";
      };

      autoAllowSkills = lib.mkOption {
        type = lib.types.bool;
        default = cfg.exec.autoAllowSkills;
        description = "Auto-allow commands from installed skills for this agent.";
      };

      allowlist = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options.pattern = lib.mkOption {
              type = lib.types.str;
              description = "Glob pattern for an allowed executable path.";
              example = "/usr/bin/git";
            };
          }
        );
        default = [ ];
        description = "Allowlisted executable patterns for this agent.";
        example = [
          { pattern = "/usr/bin/git"; }
          { pattern = "/usr/bin/az"; }
        ];
      };
    };
  };
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

    tls = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use TLS (wss://) for the gateway connection. Required for HTTPS public URLs.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments passed to `openclaw node run`.";
      example = [
        "--tls-fingerprint"
        "abc123"
      ];
    };

    # -- Exec approval settings ------------------------------------------------

    exec = {
      security = lib.mkOption {
        type = lib.types.enum [
          "deny"
          "allowlist"
          "full"
        ];
        default = "deny";
        description = ''
          Default exec security mode for the node host.
          - deny: block all host exec requests.
          - allowlist: allow only allowlisted commands.
          - full: allow everything.
        '';
      };

      ask = lib.mkOption {
        type = lib.types.enum [
          "off"
          "on-miss"
          "always"
        ];
        default = "on-miss";
        description = ''
          Default approval prompt behaviour.
          - off: never prompt.
          - on-miss: prompt when allowlist does not match.
          - always: prompt on every command.
        '';
      };

      askFallback = lib.mkOption {
        type = lib.types.enum [
          "deny"
          "allowlist"
          "full"
        ];
        default = "deny";
        description = "Fallback when no approval UI is available.";
      };

      autoAllowSkills = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Auto-allow commands from installed agent skills.";
      };

      agents = lib.mkOption {
        type = lib.types.attrsOf agentExecModule;
        default = { };
        description = ''
          Per-agent exec approval overrides. Keys are agent names (e.g. "main").
        '';
        example = {
          main = {
            security = "allowlist";
            ask = "on-miss";
            allowlist = [
              { pattern = "/usr/bin/git"; }
              { pattern = "/usr/bin/az"; }
            ];
          };
        };
      };
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

    # -- exec approvals config -----------------------------------------------
    # Write ~/.openclaw/exec-approvals.json for the node user.
    # Uses a systemd tmpfiles rule so it's created before the service starts.
    systemd.tmpfiles.rules = [
      "d /home/${cfg.user}/.openclaw 0700 ${cfg.user} users -"
      "f /home/${cfg.user}/.openclaw/exec-approvals.json 0600 ${cfg.user} users - ${builtins.toJSON execApprovalsJson}"
    ];

    # -- systemd service -----------------------------------------------------
    systemd.services.openclaw-node = {
      description = "OpenClaw node host (${cfg.displayName})";
      after = [
        "network-online.target"
        "sops-nix.service"
        "systemd-tmpfiles-setup.service"
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
          ++ lib.optionals cfg.tls [ "--tls" ]
          ++ cfg.extraArgs
        );
        EnvironmentFile = config.sops.templates."openclaw-node-env".path;
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
