{ pkgs, ... }:
# Baseline pi wrapper config shared by every pi variant: a baseline of CLI
# tools on pi's runtime PATH (so the built-in `bash` tool and extensions can
# use them without polluting the user's global PATH) plus the always-on
# Catppuccin theme. Variants compose this module and accumulate more
# extensions on top (the `extensions`/`runtimePkgs` lists append).
{
  imports = [ ./module.nix ];
  package = pkgs.pi-coding-agent;

  runtimePkgs = with pkgs; [
    jq # JSON wrangling for ad-hoc bash tool work
    gh # GitHub CLI for repo lookups / PR work
    lazygit # quick git TUI (extensions may shell out to it)
    bat # nicer file viewer for `bash` tool output
    tree # quick directory inspection
    delta # diff viewer (useful from the bash tool)
    agent-browser # headless browser automation CLI for agents
  ];

  extensions = [ pkgs.piExtensions.pi-catppuccin ]; # Catppuccin theme pack for pi TUI
}
