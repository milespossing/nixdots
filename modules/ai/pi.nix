{ config, ... }:
{
  # Desktop hosts (euler, laplace) install the desktop pi variant. The WSL host
  # gets `pi-coding-agent-wsl` from the wsl branch instead.
  flake.modules.nixos.desktop-core =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (config.flake.wrappers.pi-coding-agent-desktop.wrap { inherit pkgs; })
      ];
    };
}
