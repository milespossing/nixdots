{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./options.nix
    ./secrets.nix
    ./opencode.nix
    ./aider.nix
    ./copilot-cli.nix
  ];

  _module.args.aiLib = import ./lib.nix { inherit lib pkgs; };
}
