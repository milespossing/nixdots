# Overlay: pin pi-coding-agent to a newer upstream release than nixpkgs
# currently ships. Override src/version + npmDepsHash only; the rest of
# the build (buildPhase, postInstall, …) comes from nixpkgs unchanged.
#
# Drop this overlay once nixos-unstable catches up to this version.
final: prev: {
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: rec {
    version = "0.80.2";

    src = prev.fetchFromGitHub {
      owner = "earendil-works";
      repo = "pi";
      tag = "v${version}";
      hash = "sha256-aKtgPc3rwHEp856jP3N7nImph0CSG+gsWq9OVci3hmE=";
    };

    npmDeps = old.npmDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-1EGs8lX8XoAnRtS+pw4lBRm24U/vtVB2loVRmZyd4Z8=";
    };
  });
}
