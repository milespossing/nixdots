{ pkgs, ... }:
# WSL / work-specific pi extensions: clipboard image paste, the Edge CDP
# bridge, and browser/web automation that pairs with them. Imported on top of
# ./baseline.nix + ./extensions-base.nix for the pi-coding-agent-wsl variant.
{
  extensions = with pkgs.piExtensions; [
    pi-wsl-images # Alt+V image paste from the Windows clipboard
    agent-browser-edge-bridge # route agent_browser through Windows Edge (CDP)
    pi-agent-browser-native # native browser automation via agent-browser
    pi-web-access # web search, URL/repo/PDF/video access
  ];
}
