{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./options.nix
    ./secrets.nix
    ./opencode.nix
    ./alexandria.nix
    ./aider.nix
    ./copilot-cli.nix
    inputs.alexandria.homeManagerModules.default
  ];

  _module.args.aiLib = import ./lib.nix { inherit lib pkgs; };
}
