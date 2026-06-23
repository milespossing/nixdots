{
  package = import ./sesh.nix;
  overlay = wlib: final: prev: {
    sesh = import ./sesh.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.sesh;
    };
  };
}
