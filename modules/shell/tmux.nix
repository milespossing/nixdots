{ config, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [
        (config.flake.wrappers.tmux.wrap { inherit pkgs; })
        pkgs.sesh
      ];
      shell.aliases.seshc = "sesh connect $(sesh list | fzf)";
    };
}
