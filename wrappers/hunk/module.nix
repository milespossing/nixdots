{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# Reusable nix-wrapper-module for hunk (https://github.com/modem-dev/hunk).
#
# hunk only reads its global config from `$XDG_CONFIG_HOME/hunk/config.toml`
# (or `$HOME/.config/...`) — there is no `--config` flag and no dedicated
# env var (see src/core/paths.ts upstream). The only lever for baking config
# into the wrapper is therefore to point XDG_CONFIG_HOME at a generated store
# directory, mirroring how nix-wrapper-modules' own `helix` module works.
#
# Caveats of this approach (documented for future readers):
#   - It hard-sets XDG_CONFIG_HOME for the hunk process tree, so hunk's child
#     git/jj/sl processes won't read `$XDG_CONFIG_HOME/<tool>/config` (they
#     still read `$HOME/.<tool>` paths). For a diff viewer this only affects
#     cosmetic diff.* settings, not correctness.
#   - hunk writes `state.json` next to config.toml; that write into the
#     read-only store dir fails silently (it's wrapped in try/catch upstream),
#     which only disables the npm update notice — irrelevant for a Nix install.
#   - Repo-local `.hunk/config.toml` is cwd-based and still takes effect.
let
  tomlType = wlib.types.structuredValueWith {
    nullable = false;
    typeName = "TOML";
  };
  hasConfig = config.settings != { } || config.extraSettings != "";
in
{
  imports = [ wlib.modules.default ];

  options = {
    settings = lib.mkOption {
      type = tomlType;
      default = { };
      example = {
        theme = "catppuccin-mocha";
        mode = "auto";
        line_numbers = true;
      };
      description = ''
        Contents of hunk's `config.toml`.
        See <https://github.com/modem-dev/hunk#config>.
      '';
    };
    extraSettings = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra raw lines appended verbatim to hunk's `config.toml`.";
    };
  };

  config = {
    binName = lib.mkDefault "hunk";
    # Upstream's locked package declares meta.mainProgram = "hunkdiff" but only
    # installs bin/hunk, so both auto-derived names (binName for the output, and
    # exePath for the binary to wrap) are wrong. Pin them to the real binary,
    # otherwise the wrapper targets a non-existent bin/hunkdiff. The base
    # package itself is supplied by the registry (from the hunk flake input).
    exePath = lib.mkDefault "bin/hunk";

    env.XDG_CONFIG_HOME = lib.mkIf hasConfig "${placeholder config.outputName}/${config.binName}-config";

    drv.extraSettings = config.extraSettings;
    drv.passAsFile = [ "extraSettings" ];

    constructFiles.config = lib.mkIf hasConfig {
      relPath = lib.mkOverride 0 "${config.binName}-config/hunk/config.toml";
      content = builtins.toJSON config.settings;
      builder = ''
        ${pkgs.remarshal}/bin/json2toml "$1" "$2"
        cat "$extraSettingsPath" >> "$2"
      '';
    };
  };
}
