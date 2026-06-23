{ pkgs, ... }:
{
  programs.worktrunk = {
    enable = true;
    package = pkgs.worktrunk;

    enableBashIntegration = true;
  };

  shell.aliases."wt-sesh" =
    "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' $(git branch | fzf | cut -c 3-)";
  shell.aliases."wtc" = "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' -c";
}
