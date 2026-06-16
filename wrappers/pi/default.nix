{
  # Primary package: the baseline-wrapped pi (runtimePkgs on PATH).
  # Exposed for downstream callers that want the simplest wrap to
  # then add their own extensions / runtimePkgs on top.
  package = import ./pi.nix;

  # The overlay defines two attributes:
  #   - pi-coding-agent     -- baseline wrap (replaces upstream)
  #   - pi-coding-agent-wsl -- baseline + every packaged extension
  #
  # The WSL variant is built from the baseline-wrapped `final.pi-coding-agent`
  # (not `prev.pi-coding-agent`) so it picks up the runtimePkgs from
  # this same overlay rather than re-wrapping the raw nixpkgs version.
  overlay = wlib: final: prev: {
    pi-coding-agent = import ./pi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.pi-coding-agent;
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
