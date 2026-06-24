{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# Reusable nix-wrapper-module for worktrunk (https://worktrunk.dev).
#
# Unlike hunk, worktrunk exposes a dedicated config-path override
# (`WORKTRUNK_CONFIG_PATH`, and a `--config` flag — see src/config/user/path.rs
# upstream), so we can bake config without hijacking XDG_CONFIG_HOME and without
# leaking env into child processes.
#
# Note: worktrunk's interactive-shell integration (`wt config shell init bash`)
# and shell aliases cannot live in a binary wrapper — they must run in the
# user's shell rc, and are wired in modules/development/worktrunk.nix.
let
  tomlType = wlib.types.structuredValueWith {
    nullable = false;
    typeName = "TOML";
  };
  hasConfig = config.settings != { };
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    type = tomlType;
    default = { };
    example = {
      worktree-path = "~/worktrees/{{repo}}/{{branch}}";
    };
    description = ''
      Contents of worktrunk's `config.toml`, delivered via
      `WORKTRUNK_CONFIG_PATH`. See <https://worktrunk.dev/config/>.
    '';
  };

  config = {
    # The base package (worktrunk flake input) is supplied by the registry.
    env.WORKTRUNK_CONFIG_PATH = lib.mkIf hasConfig "${placeholder config.outputName}/${config.binName}-config/config.toml";

    constructFiles.config = lib.mkIf hasConfig {
      relPath = lib.mkOverride 0 "${config.binName}-config/config.toml";
      content = builtins.toJSON config.settings;
      builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
    };
  };
}
