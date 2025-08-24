{ config, inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      openai_api_key = {
        sopsFile = ../../secrets/openai.yaml;
        path = "${config.home.homeDirectory}/.secrets/openai";
      };
    };
  };
}
