# Overlay: pin pi-coding-agent to a newer upstream release than nixpkgs
# currently ships. Override src/version + npmDepsHash only; the rest of
# the build (buildPhase, postInstall, …) comes from nixpkgs unchanged.
#
# Drop this overlay once nixos-unstable catches up to this version.
final: prev: {
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: rec {
    version = "0.79.4";

    src = prev.fetchFromGitHub {
      owner = "earendil-works";
      repo = "pi";
      tag = "v${version}";
      hash = "sha256-cAlQfKtT8kLoAHYvXusbpM2I9FrRijWzSPQDSy/Kkro=";
    };

    npmDeps = old.npmDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-y3wwz0orFrUPu4XRJnHRkO9x9s+GMtBP/2g7kN336vQ=";
    };
  });
}
