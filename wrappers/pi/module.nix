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

  options.appendSystemPromptFiles = lib.mkOption {
    type = lib.types.listOf wlib.types.stringable;
    default = [ ];
    description = ''
      Files to append to pi's system prompt on every invocation.

      Pi's built-in AGENTS.md discovery only searches the global agent
      directory and the current working directory's ancestors. For a
      wrapper-local AGENTS.md, pass its path with
      `--append-system-prompt`; pi reads file contents when the value is
      an existing path. Project context files are still loaded later and
      can provide more specific instructions.
    '';
    example = lib.literalExpression "[ ./AGENTS.md ]";
  };

  # Ship the wrapper-local instructions inside the derivation, then
  # append them via CLI. This avoids taking over ~/.pi/agent just to
  # provide global context for this wrapper.
  config.constructFiles.wrapperAgents = {
    relPath = "share/pi/AGENTS.md";
    content = builtins.readFile ./AGENTS.md;
  };

  config.appendSystemPromptFiles = lib.mkBefore [ config.constructFiles.wrapperAgents.path ];

  # `ifs = null` tells nix-wrapper-modules to repeat each flag for
  # each item rather than join them. Empty lists emit no flags.
  config.flags."--append-system-prompt" = {
    ifs = null;
    data = map toString config.appendSystemPromptFiles;
  };

  config.flags."--extension" = {
    ifs = null;
    data = map toString config.extensions;
  };
}
