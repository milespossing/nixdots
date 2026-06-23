{ inputs, ... }:
{
  flake.modules.homeManager.dev = {
    imports = [ inputs.worktrunk-flake.homeModules.default ];
    programs.worktrunk = {
      enable = true;
      enableBashIntegration = true;
    };
    shell.aliases = {
      wt-sesh = "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' $(git branch | fzf | cut -c 3-)";
      wtc = "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' -c";
    };
  };
}
