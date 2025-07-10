{ config, ... }:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      openai_api_key = {
        sopsFile = ../secrets/openai.yaml;
        path = "${config.home.homeDirectory}/.secrets/openai";
      };
      github_hosts = {
        sopsFile = ../secrets/github-hosts.yaml;
        path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
        key = "";
      };
    };
  };
}
