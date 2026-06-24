{ config, ... }:
{
  # worktrunk: Git worktree management CLI (https://worktrunk.dev).
  #
  # The binary is installed at the system layer, wrapped via wrappers/worktrunk
  # (base package is the worktrunk flake input, injected into the overlay in
  # modules/flake/wrappers.nix).
  flake.modules.nixos.dev =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (config.flake.wrappers.worktrunk.wrap { inherit pkgs; }) ];
    };

  # Its interactive-shell integration (the bash-init hook + the wt-sesh/wtc
  # aliases) must run in the user's shell, so it stays in the shell layer
  # alongside fzf/zoxide/atuin/direnv. References the wrapped pkgs.worktrunk.
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      shell.initExtra = ''
        eval "$(${config.flake.wrappers.worktrunk.wrap { inherit pkgs; }}/bin/wt config shell init bash)"
      '';
      shell.aliases = {
        wt-sesh = "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' $(git branch | fzf | cut -c 3-)";
        wtc = "wt switch --no-cd -x 'sesh connect {{ worktree_path }}' -c";
      };
    };
}
