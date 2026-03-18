{ lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types;

  mcpServerType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [
          "local"
          "remote"
        ];
        description = "MCP server connection type.";
      };
      command = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Command and arguments for local MCP servers.";
      };
      url = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "URL for remote MCP servers.";
      };
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Whether this MCP server is enabled.";
      };
      environment = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Environment variables for local MCP servers.";
      };
      headers = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Headers for remote MCP servers.";
      };
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Optional package providing the MCP server binary. Auto-added to OpenCode's wrapper PATH.";
      };
    };
  };

  skillType = types.submodule {
    options = {
      description = mkOption {
        type = types.str;
        default = "";
        description = "Short description (1-1024 chars) for agent discovery. Not required when source is set.";
      };
      content = mkOption {
        type = types.lines;
        default = "";
        description = "Markdown body of the SKILL.md (after frontmatter). Not required when source is set.";
      };
      source = mkOption {
        type = types.nullOr (types.either types.path types.str);
        default = null;
        description = ''
          Path to a complete SKILL.md file (frontmatter + body).
          When set, description/content are ignored and the file is deployed verbatim.
          Accepts a local path or a string path (e.g. from fetchFromGitHub).
        '';
      };
      license = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional license identifier.";
      };
      compatibility = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional compatibility tag (e.g. 'opencode').";
      };
      metadata = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Optional string-to-string metadata map.";
      };
    };
  };
in
{
  options.my.ai = {
    opencode = {
      enable = mkEnableOption "OpenCode AI coding agent";
      lspServers = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          nixd
          lua-language-server
          gopls
          typescript-language-server
          clojure-lsp
        ];
        description = "LSP server packages to inject into OpenCode's PATH.";
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Additional packages to inject into OpenCode's PATH (e.g. MCP server binaries).";
      };
      plugins = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          OpenCode plugin packages. Each entry is an npm package name
          (optionally with @version). Added to the "plugin" key in opencode.json.
          OpenCode auto-installs plugins on startup.
        '';
        example = [
          "opencode-notify"
          "opencode-direnv"
        ];
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = ''
          Additional OpenCode config keys merged into ~/.config/opencode/opencode.json.
          Keys like "model", "provider", "tools", "permissions", etc.
        '';
      };
    };

    copilot-cli = {
      enable = mkEnableOption "GitHub Copilot CLI";
    };

    aider = {
      enable = mkEnableOption "Aider AI pair programming";
      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = ''
          Additional aider config keys merged into ~/.aider.conf.yml.
          See https://aider.chat/docs/config/aider_conf.html
        '';
      };
    };

    mcp.servers = mkOption {
      type = types.attrsOf mcpServerType;
      default = { };
      description = "MCP servers. Currently consumed by OpenCode; written to its global config.";
    };

    skills = mkOption {
      type = types.attrsOf skillType;
      default = { };
      description = ''
        Agent skills deployed as SKILL.md files.
        Each key becomes a directory under ~/.config/opencode/skills/<name>/SKILL.md.
        Skills are discovered on-demand by OpenCode's skill tool.
      '';
    };

    rules = {
      global = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Global rules written to ~/.config/opencode/AGENTS.md.
          Also provided to Aider as a read-only conventions file when aider is enabled.
        '';
      };
      instructionFiles = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Additional instruction file paths or globs for OpenCode's "instructions" config key.
          Also added to Aider's "read" config when aider is enabled.
        '';
      };
    };
  };
}
