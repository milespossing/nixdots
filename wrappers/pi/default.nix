{
  # Primary package: the baseline-wrapped pi (runtimePkgs on PATH).
  # Exposed for downstream callers that want the simplest wrap to
  # then add their own extensions / runtimePkgs on top.
  package = import ./pi.nix;

  # The overlay defines these pi package variants:
  #   - pi-coding-agent     -- baseline wrap (replaces upstream)
  #   - pi-coding-agent-psi -- baseline + Copilot discovery, command: psi
  #   - pi-coding-agent-phi -- psi + todo, command: phi
  #   - pi-coding-agent-wsl -- baseline + every packaged extension
  #
  # The named variants are built from already-wrapped `final.*` packages
  # (not raw `prev.pi-coding-agent`) so each .wrap extends the existing
  # nix-wrapper-modules configuration instead of losing baseline PATH
  # tools or earlier extensions.
  overlay = wlib: final: prev: {
    pi-coding-agent = import ./pi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.pi-coding-agent;
    };
    pi-coding-agent-psi = import ./psi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent;
    };
    pi-coding-agent-phi = import ./phi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent-psi;
    };
    pi-coding-agent-wsl = import ./pi-wsl.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent;
    };

    # Layer locally-built pi extensions onto the upstream
    # `pkgs.piExtensions` attrset (from overlays/pi-extensions). Keeping
    # them here means consumers can write
    # `pkgs.piExtensions.agent-browser-edge-bridge` the same way they
    # write `pkgs.piExtensions.pi-agent-browser-native`.
    piExtensions = (prev.piExtensions or { }) // {
      agent-browser-edge-bridge = final.callPackage ./extensions/agent-browser-edge-bridge { };
    };
  };
}
