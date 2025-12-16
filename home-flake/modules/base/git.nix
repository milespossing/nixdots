{
  ...
}:
{
  programs.git = {
    enable = true;
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
    };
  };

  programs.gh = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };
}
