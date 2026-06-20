{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zathura
    pi-coding-agent-wsl # WSL/work pi (base + WSL-specific extensions)
  ];
}
