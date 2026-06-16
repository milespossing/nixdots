{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent,
}:
# Pi coding agent wrapper. Adds a baseline of CLI tools to pi's
# runtime PATH so the built-in `bash` tool and extensions can use them
# without polluting the user's global PATH. Per-host home-manager
# modules can call `.wrap { runtimePkgs = ...; extensions = ...; }`
# on the result to layer more in.
wlib.evalPackage [
  (import ./module.nix)
  {
    inherit pkgs;
    package = basePackage;

    runtimePkgs = with pkgs; [
      jq # JSON wrangling for ad-hoc bash tool work
      gh # GitHub CLI for repo lookups / PR work
      lazygit # quick git TUI (extensions may shell out to it)
      bat # nicer file viewer for `bash` tool output
      tree # quick directory inspection
      delta # diff viewer (pi already does its own diffs but useful in bash)
      agent-browser # headless browser automation CLI for agents
    ];
  }
]
