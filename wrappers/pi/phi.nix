{
  pkgs,
  wlib,
  basePackage ? pkgs.pi-coding-agent-psi,
}:
# Phi: a slightly larger named pi variant. It deliberately builds on
# psi and adds only the todo extension for now, leaving psi's baseline
# runtime PATH and Copilot discovery extension intact.
#
# The mkAfter on extensions keeps the layering readable in the final
# config: psi's Copilot discovery first, phi's todo extension second.
let
  inherit (pkgs) lib;
in
basePackage.wrap {
  drv = {
    pname = lib.mkOverride 900 "pi-coding-agent-phi";
    name = lib.mkOverride 900 "pi-coding-agent-phi-${basePackage.version or "unknown"}";
  };

  # Stronger than psi's mkDefault, but still weaker than a normal
  # downstream assignment if a future wrapper wants another name.
  binName = lib.mkOverride 900 "phi";

  # If phi is ever built from a realized psi wrapper, don't leak a
  # second command name. When .wrap extends psi's module config this
  # simply accumulates with psi's existing `bin/pi` exclusion.
  filesToExclude = lib.mkAfter [ "bin/psi" ];

  extensions =
    with pkgs.piExtensions;
    lib.mkAfter [
      rpiv-todo # live todo overlay that survives reload / compaction
    ];
}
