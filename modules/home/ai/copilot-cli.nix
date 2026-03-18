{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ai.copilot-cli;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.github-copilot-cli
    ];
  };
}
