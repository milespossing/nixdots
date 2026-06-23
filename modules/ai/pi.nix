{
  # Desktop hosts (euler, laplace) install the desktop pi variant. The WSL host
  # gets `pi-coding-agent-wsl` from the wsl branch instead.
  flake.modules.nixos.desktop-core =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.pi-coding-agent-desktop ];
    };
}
