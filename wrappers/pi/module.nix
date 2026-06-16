{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# Pi-specific wrapper module options on top of wlib.modules.default.
#
# Adds an `extensions` list that the wrapper translates into
# `--extension <path>` flags on pi's command line. Each entry can be
# a derivation (e.g. `pkgs.piExtensions.pi-wsl-images`), a path, or
# anything stringable.
#
# Pi resolves a `--extension <dir>` by reading the package's `pi`
# manifest in `package.json` (or falling back to convention dirs like
# `extensions/`, `skills/`, `prompts/`, `themes/`). So a single
# extension entry can deliver multiple resources to pi.
{
  imports = [ wlib.modules.default ];

  options.extensions = lib.mkOption {
    type = lib.types.listOf wlib.types.stringable;
    default = [ ];
    description = ''
      Pi extensions / pi-packages to load on every invocation.

      Each entry becomes a `--extension <path>` flag on pi. Local
      directories are auto-detected as packages (pi reads their
      `package.json` `pi` manifest, or falls back to convention
      directories like `extensions/`, `skills/`, etc.).
    '';
    example = lib.literalExpression "[ pkgs.piExtensions.pi-wsl-images ]";
  };

  # `ifs = null` tells nix-wrapper-modules to repeat the flag for
  # each item rather than join them. Result: `--extension <a>
  # --extension <b> ...`. Empty list -> no flag emitted.
  config.flags."--extension" = {
    ifs = null;
    data = map toString config.extensions;
  };
}
