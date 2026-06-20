{
  # Primary package: the baseline-wrapped pi (runtimePkgs on PATH).
  # Exposed for downstream callers that want the simplest wrap to
  # then add their own extensions / runtimePkgs on top.
  package = import ./pi.nix;

  # The overlay defines these pi package variants:
  #   - pi-coding-agent-upstream -- version-pinned upstream, no wrapping
  #   - pi-coding-agent          -- baseline wrap (runtimePkgs on PATH)
  #   - pi-coding-agent-base     -- common wrapper: baseline + shared extensions
  #   - pi-coding-agent-desktop  -- base, for graphical hosts (euler, laplace)
  #   - pi-coding-agent-wsl      -- base + WSL/work-specific extensions
  #
  # The wrapped variants are built from already-wrapped `final.*`
  # packages (not raw `prev.pi-coding-agent`) so each .wrap extends the
  # existing nix-wrapper-modules configuration instead of losing
  # baseline PATH tools or earlier extensions. pi-desktop and pi-wsl
  # are the two flavours we actually install on hosts; both layer on
  # the common pi-coding-agent-base.
  overlay = wlib: final: prev: {
    # Raw upstream pi (version-pinned by overlays/pi-coding-agent.nix),
    # before any of our wrapping. Exposed for `nix run .#pi-upstream`.
    pi-coding-agent-upstream = prev.pi-coding-agent;

    pi-coding-agent = import ./pi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.pi-coding-agent;
    };
    pi-coding-agent-base = import ./pi-base.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent;
    };
    pi-coding-agent-desktop = import ./pi-desktop.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent-base;
    };
    pi-coding-agent-wsl = import ./pi-wsl.nix {
      pkgs = final;
      inherit wlib;
      basePackage = final.pi-coding-agent-base;
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
