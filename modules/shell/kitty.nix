{
  # kitty is configured by its nix-wrapper-modules overlay (wrappers/kitty),
  # the single source of truth for its config (decision #2). Just install it.
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kitty ];
    };
}
