{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.ai;
  sopsFile = ./api-keys.enc.yaml;

  # Keep in sync with api-keys.enc.yaml
  keys = [
    "github"
    "skillsmp"
  ];
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf (cfg.opencode.enable || cfg.copilot-cli.enable || cfg.alexandria.enable) {
    sops = {
      age.keyFile = lib.mkDefault "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      secrets = lib.genAttrs keys (key: {
        inherit sopsFile;
      });

      templates."ai-env".content = lib.concatStringsSep "\n" (
        [ "export GITHUB_TOKEN=${config.sops.placeholder.github}" ]
        ++ lib.optional (
          cfg.skills ? skillsmp-search
        ) "export SKILLSMP_API_KEY=${config.sops.placeholder.skillsmp}"
      );
    };
  };
}
