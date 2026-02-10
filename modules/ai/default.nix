{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    github-copilot-cli
  ];
}
