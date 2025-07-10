{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.git;
in
{
  options.programs.git = {
    gcmCoreIntegration = {
      enable = mkEnableOption "Uses GCM";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      userName = "Miles Possing";
      ignores = [
        "*~"
        "*.swp"
        ".\\#*"
        "\\#*\\#"
        "venv/"
        ".direnv"
        ".envrc"
      ];
      aliases = {
        s = "status";
        c = "checkout";
        d = "diff";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        diff.tool = "nvimdiff";
        merge.tool = "nvimdiff";
        http.postBuffer = 524288000;
        mergetool = {
          keepBackup = false;
        };
        push.autoSetupRemote = true;
        core = {
          editor = "nvim";
          pager = "bat";
        };
        credential = {
          useHttpPath = mkIf cfg.gcmCoreIntegration.enable true;
        };
      };
    };

    programs.gh = {
      enable = true;
    };
  };
}
