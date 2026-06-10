# Overlay: pin kulala.nvim to a newer upstream tag than what nixos-unstable
# currently ships, and detach the build from kulala-core (which has a hash
# mismatch in nixpkgs right now). With the postPatch stripped, kulala falls
# back to its default behavior of auto-downloading kulala-core from GitHub
# releases on first use.
final: prev: {
  vimPlugins = prev.vimPlugins // {
    kulala-nvim = prev.vimPlugins.kulala-nvim.overrideAttrs (_old: {
      version = "6.9.2";
      src = final.fetchFromGitHub {
        owner = "mistweaverco";
        repo = "kulala.nvim";
        tag = "v6.9.2";
        hash = "sha256-7q/lV939qxozpsE0SM272ztSdzqIDuAdrgXSITCDLko=";
        fetchSubmodules = true;
      };
      postPatch = "";
    });
  };
}
