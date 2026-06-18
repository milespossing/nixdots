{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent,
}:
# Psi: a small named pi variant. It starts from the baseline pi
# wrapper and adds only live GitHub Copilot model discovery.
#
# `basePackage.wrap` extends the existing nix-wrapper-modules
# configuration rather than losing it, so psi keeps the baseline
# runtime PATH from `pi.nix` and only adds the extension below.
let
  inherit (pkgs) lib;
in
basePackage.wrap {
  drv = {
    pname = lib.mkDefault "pi-coding-agent-psi";
    name = lib.mkDefault "pi-coding-agent-psi-${basePackage.version or "unknown"}";
  };

  # Keep this as a default so future variants can wrap psi and rename
  # the command without needing mkForce.
  binName = lib.mkDefault "psi";

  # The package should install a distinct `psi` command, not another
  # `pi` binary that collides with the base wrapper.
  filesToExclude = [ "bin/pi" ];

  extensions = with pkgs.piExtensions; [
    pi-copilot-discovery # live Copilot model discovery (replaces static catalog)
  ];
}
