{ config, lib, ... }:
with lib;
let cfg = config.mp.programs.git;
in {
  options.mp.programs.git = {
    enable = mkEnableOption "Enables git";
    user = mkOption {
      type = types.str;
      default = "Miles Possing";
      description = "User Name for git";
    };
    email = mkOption {
      type = types.str;
      default = "git@possing.tech";
      description = "Email to use for git";
    };
    gcmCoreIntegration = {
      enable = mkEnableOption "Uses GCM";
      location = mkOption {
        type = types.str;
        default = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
        description = "Where is the gcm located";
      };
    };
  };

  config.programs.git = mkIf cfg.enable {
    enable = true;
    userName = cfg.user;
    userEmail = cfg.email;
    ignores = [ "*~" "*.swp" "#*#" "venv/" ".direnv" ".envrc" ];
    aliases = {
      s = "status";
      c = "checkout";
      d = "diff";
    };
    extraConfig = {
      pull.rebase = false;
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      mergetool = {
        keepBackup = false;
      };
      core = {
        editor = "nvim";
        pager = "bat";
      };
      credential = mkIf cfg.gcmCoreIntegration.enable {
        helper = cfg.gcmCoreIntegration.location;
        useHttpPath = true;
      };
    };
  };
}
