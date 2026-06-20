{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent-base,
}:
# Desktop pi: the variant installed on the graphical hosts (euler,
# laplace). It builds on the common pi-base wrapper and currently adds
# no extra extensions -- it exists as a named hook so desktop-only
# extensions can be layered here later without touching the WSL bundle
# or the shared base set.
let
  inherit (pkgs) lib;
in
basePackage.wrap {
  drv = {
    pname = lib.mkDefault "pi-coding-agent-desktop";
    name = lib.mkDefault "pi-coding-agent-desktop-${basePackage.version or "unknown"}";
  };

  # Desktop-specific extensions go here. Left empty for now; the base
  # wrapper's extensions still apply because `.wrap` accumulates the
  # list rather than replacing it.
  extensions = [ ];
}
