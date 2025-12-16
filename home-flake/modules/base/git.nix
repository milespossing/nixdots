{
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Miles Possing";
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
}
