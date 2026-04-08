{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.ai;
in
{
  imports = [
    inputs.charmbracelet-nur.homeModules.crush
  ];

  config = lib.mkIf cfg.crush.enable {
    programs.crush = {
      enable = true;
      settings = {
        options = {
          disable_provider_auto_update = true;
          disable_metrics = true;
        };
        models = {
          default = {
            provider = "copilot";
            model = "claude-opus-4.6-1m";
          };
        };
      };
    };
  };
}
