{
  package = import ./yazi.nix;
  overlay = wlib: final: prev: {
    yazi = import ./yazi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.yazi;
    };
  };
}
