{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./fish.nix
    ./zsh.nix
  ];
  options.shell = {
    aliases = mkOption {
      type = with types; attrsOf str;
      default = {
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
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
    shell.envExtra.OPENAI_API_KEY = "$(cat ${config.sops.secrets.openai_api_key.path})";
    programs.nushell = {
      enable = true;
    };

    home.file.".scripts/fzf-git.sh" = {
      source = ./fzf-git.sh;
    };
  };
}
