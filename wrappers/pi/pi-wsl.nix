{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent-base,
}:
# WSL / work pi: takes the common pi-base wrapper (baseline runtimePkgs
# plus our shared default extensions) and layers on only the
# WSL-specific extensions -- clipboard image paste, the Edge CDP
# bridge, and browser/web automation that pairs with them.
#
# Intended consumers:
#   - the `nixos` (WSL/work) host's system package set
#   - `nix run .#pi-wsl` from any WSL host that doesn't have the
#     nixos config installed
#
# `basePackage` defaults to `pkgs.pi-coding-agent-base`, so this is a
# further `.wrap` that only adds the extensions below; the shared base
# extensions accumulate rather than being replaced.
basePackage.wrap {
  extensions = with pkgs.piExtensions; [
    pi-wsl-images # Alt+V image paste from the Windows clipboard
    agent-browser-edge-bridge # route agent_browser through Windows Edge (CDP)
    pi-agent-browser-native # native browser automation via agent-browser
    pi-web-access # web search, URL/repo/PDF/video access
  ];
}
