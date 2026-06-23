{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  ai = cfg.aider;

  # Bridge shared rules into Aider's conventions system.
  # Aider's `read:` key loads files as read-only context.
  # We write the global rules to a file and point Aider at it.
  rulesFile = "~/.config/opencode/AGENTS.md";
  hasGlobalRules = cfg.rules.global != "";

  readFiles = (lib.optional hasGlobalRules rulesFile) ++ cfg.rules.instructionFiles;

  # Build .aider.conf.yml content
  aiderConfig =
    lib.optionalAttrs (readFiles != [ ]) {
      read = readFiles;
    }
    // ai.extraConfig;

  # Simple YAML serializer for flat/list values (sufficient for aider config)
  toYamlValue =
    v:
    if builtins.isList v then
      "\n" + lib.concatMapStringsSep "\n" (item: "  - ${toString item}") v
    else if builtins.isBool v then
      (if v then "true" else "false")
    else if builtins.isInt v then
      toString v
    else
      toString v;

  aiderYaml = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "${k}: ${toYamlValue v}") aiderConfig
  );
in
{
  config = lib.mkIf ai.enable {
    home.packages = [
      pkgs.aider-chat
    ];

    # ~/.aider.conf.yml — global aider config
    home.file.".aider.conf.yml" = lib.mkIf (aiderConfig != { }) {
      text = ''
        # Managed by home-manager — modules/home/ai/aider.nix
        ${aiderYaml}
      '';
    };
  };
}
