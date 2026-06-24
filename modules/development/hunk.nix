{ config, ... }:
{
  # hunk: review-first terminal diff viewer for agent-authored changesets.
  # https://github.com/modem-dev/hunk
  #
  # Installed at the system layer. The binary + baked config.toml come from the
  # nix-wrapper-module in wrappers/hunk (config is delivered via XDG_CONFIG_HOME,
  # since hunk has no --config flag / env override). The base package is the
  # `hunk` flake input, injected into the overlay in modules/flake/wrappers.nix.
  flake.modules.nixos.dev =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (config.flake.wrappers.hunk.wrap { inherit pkgs; }) ];
    };
}
