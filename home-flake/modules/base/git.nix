{
  config,
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
  };
}
