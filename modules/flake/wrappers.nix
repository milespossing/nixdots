{ inputs, config, ... }:
# nix-wrapper-modules, Variant B: wrappers are defined in the flake-parts
# `flake.wrappers` registry and consumed explicitly via
# `config.flake.wrappers.<n>.wrap { inherit pkgs; }`. There is no wrapper
# overlay — `pkgs.<n>` stays vanilla upstream. The flake-parts module also
# auto-exposes each wrapper as `packages.<system>.<n>` (nix build/run).
let
  # Local pi extension layered onto the upstream `pkgs.piExtensions` set. This
  # is a package addition (not a wrapper), so it stays an overlay.
  edgeBridgeOverlay = final: prev: {
    piExtensions = (prev.piExtensions or { }) // {
      agent-browser-edge-bridge =
        final.callPackage ../../wrappers/pi/extensions/agent-browser-edge-bridge
          { };
    };
  };

  # Non-wrapper overlays that provide base packages the wrappers build on:
  # the version-pinned upstream pi-coding-agent and the pi extension set.
  basePkgOverlays = [
    (import ../../overlays/pi-coding-agent.nix)
    (import ../../overlays/pi-extensions)
    edgeBridgeOverlay
  ];
in
{
  imports = [ inputs.nix-wrapper-modules.flakeModules.wrappers ];

  flake.modules.nixos.base.nixpkgs.overlays = basePkgOverlays;

  flake.wrappers = {
    # Simple wrappers (base package from vanilla nixpkgs).
    kitty = import ../../wrappers/kitty/kitty.nix;
    rofi = import ../../wrappers/rofi/rofi.nix;
    dunst = import ../../wrappers/dunst/dunst.nix;
    swaylock-effects = import ../../wrappers/swaylock/swaylock.nix;
    waybar = import ../../wrappers/waybar/waybar.nix;
    yazi = import ../../wrappers/yazi/yazi.nix;

    # noctalia desktop shell — base package from the noctalia flake input
    # (resolved per-system via the wrap-time pkgs, like hunk/worktrunk).
    noctalia =
      { pkgs, ... }:
      {
        imports = [ ../../wrappers/noctalia/noctalia.nix ];
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

    # tmux launches the wrapped yazi + worktrunk. With no overlay we thread the
    # registry packages in explicitly (built against the same wrap-time pkgs).
    tmux =
      { pkgs, ... }:
      {
        imports = [ ../../wrappers/tmux/tmux.nix ];
        _module.args.wt = "${config.flake.wrappers.worktrunk.wrap { inherit pkgs; }}/bin/wt";
        _module.args.yaziBin = "${config.flake.wrappers.yazi.wrap { inherit pkgs; }}/bin/yazi";
      };

    # Base packages from flake inputs (resolved per-system via the wrap-time
    # pkgs — the wrapper analogue of flake-parts `inputs'`).
    worktrunk =
      { pkgs, ... }:
      {
        imports = [ ../../wrappers/worktrunk/module.nix ];
        package = inputs.worktrunk-flake.packages.${pkgs.stdenv.hostPlatform.system}.worktrunk;
      };
    hunk =
      { pkgs, ... }:
      {
        imports = [ ../../wrappers/hunk/module.nix ];
        package = inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          theme = "catppuccin-mocha";
          mode = "auto";
          line_numbers = true;
        };
      };

    # pi variant chain, composed at the module level — the baseline + extension
    # modules merge (the `extensions`/`runtimePkgs` lists accumulate), so each
    # variant is a single wrapper rather than a wrapper-of-a-wrapper.
    pi-coding-agent = import ../../wrappers/pi/baseline.nix;
    pi-coding-agent-base.imports = [
      ../../wrappers/pi/baseline.nix
      ../../wrappers/pi/extensions-base.nix
    ];
    pi-coding-agent-desktop =
      { lib, ... }:
      {
        imports = [
          ../../wrappers/pi/baseline.nix
          ../../wrappers/pi/extensions-base.nix
        ];
        drv.name = lib.mkDefault "pi-coding-agent-desktop";
      };
    pi-coding-agent-wsl =
      { lib, ... }:
      {
        imports = [
          ../../wrappers/pi/baseline.nix
          ../../wrappers/pi/extensions-base.nix
          ../../wrappers/pi/extensions-wsl.nix
        ];
        drv.name = lib.mkDefault "pi-coding-agent-wsl";
      };
  };

  # Build the auto-exposed `packages.<system>.<n>` against a pkgs carrying the
  # non-wrapper base overlays (pi-coding-agent / piExtensions) the pi wrappers
  # need. Simple wrappers ignore these and use vanilla nixpkgs.
  perSystem =
    { system, ... }:
    {
      wrappers.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = basePkgOverlays;
      };
    };
}
