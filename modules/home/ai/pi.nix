{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  pi = cfg.pi;

  # Pi auto-loads ~/.pi/agent/AGENTS.md (and CLAUDE.md) as global context
  # files. Mirror the shared rules into that location so all agents share
  # one source of truth. Pi never writes to context files, so a /nix/store
  # symlink is safe.
  hasRules = cfg.rules.global != "";

  # ~/.pi/agent/settings.json is mutable: pi rewrites it on `/set` commands
  # and stores UI state there. We don't manage it declaratively to avoid
  # clobbering user changes (similar to how crush.nix avoids managing
  # ~/.local/share/crush/crush.json). Use PI_CODING_AGENT_DIR if you need
  # to relocate the whole dir.
in
{
  config = lib.mkIf pi.enable {
    home.packages = [ pkgs.pi-coding-agent ];

    home.file = lib.mkIf hasRules {
      ".pi/agent/AGENTS.md".text = cfg.rules.global;
    };
  };
}
