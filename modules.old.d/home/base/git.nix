{
  config,
  pkgs,
  ...
}:
{
  config = {
    programs.git = {
      enable = true;
      settings = {
        user.name = config.my.alias.name;
        user.email = config.my.alias.email;
        aliases = {
          s = "status";
          c = "checkout";
          d = "diff";
        };
        init.defaultBranch = "main";
        pull.rebase = false;
        diff.tool = "nvimdiff";
        diff.colorMoved = "default";
        merge.tool = "nvimdiff";
        http.postBuffer = 524288000;
        mergetool = {
          keepBackup = false;
        };
        push.autoSetupRemote = true;
        core = {
          editor = "nvim";
          pager = "delta";
        };
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          dark = true;
          line-numbers = true;
          syntax-theme = "Catppuccin Mocha";
        };
      };
      ignores = [
        "*~"
        "*.swp"
        ".\\#*"
        "\\#*\\#"
        "venv/"
        ".direnv"
        ".envrc"
      ];
    };

    programs.gh = {
      enable = true;
    };

    programs.lazygit = {
      enable = true;
    };

    home.packages = with pkgs; [
      delta
    ];
  };
}
