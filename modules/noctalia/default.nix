{
  package = import ./noctalia.nix;
  overlay = wlib: final: prev: {
    noctalia-shell = import ./noctalia.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.noctalia-shell;
    };
  };
}
