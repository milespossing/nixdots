{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
{
  options.shell = {
    aliases = mkOption {
      type = with types; attrsOf str;
      default = {
        fzfp = "fzf --preview 'bat --color=always {}' --preview-window '~3'";
      };
    };
    initExtra = mkOption {
      type = types.lines;
      default = "";
      description = "Extra init for posix shells";
    };
    pathDirs = mkOption {
      type = types.envVar;
      default = "/usr/local/bin";
    };
    envExtra = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "Extra environment variables for shells";
    };
  };

  config = {
    programs.nushell = {
      enable = true;
    };

    programs.bash = {
      enable = true;
      shellAliases = config.shell.aliases;
      initExtra = config.shell.initExtra;
      sessionVariables = config.shell.envExtra;
    };

    programs.fish = {
      enable = true;
      generateCompletions = true;
      shellAliases = config.shell.aliases;
      shellInit = config.shell.initExtra;
      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
    };
  };
}
