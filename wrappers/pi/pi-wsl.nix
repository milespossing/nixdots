{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent,
}:
# WSL-flavoured pi: takes the baseline-wrapped pi (with the standard
# runtimePkgs already on PATH) and layers on every pi extension we
# package in `overlays/pi-extensions`.
#
# Intended consumers:
#   - `nix run .#pi-wsl` from any WSL host that doesn't have the
#     nixos config installed
#   - downstream flakes that want a ready-to-use pi with the
#     clipboard + slash-command + browser bundle
#
# `basePackage` defaults to `pkgs.pi-coding-agent` which, after the
# wrappers overlay runs, is already the baseline wrap. So this is a
# second-pass `.wrap` that only sets `extensions`. nix-wrapper-modules
# composes the two wraps cleanly.
basePackage.wrap {
  extensions = with pkgs.piExtensions; [
    pi-wsl-images # Alt+V image paste from the Windows clipboard
    rpiv-btw # /btw slash command for side questions
    pi-copilot-discovery # live Copilot model discovery (replaces static catalog)
    pi-agent-browser-native # native browser automation via agent-browser
    agent-browser-edge-bridge # transparently route agent_browser through Windows Edge (CDP)
  ];
}
