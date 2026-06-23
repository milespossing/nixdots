{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tmux
        sesh
      ];
      shell.aliases.seshc = "sesh connect $(sesh list | fzf)";
    };
}
