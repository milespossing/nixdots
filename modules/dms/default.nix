{
  package = import ./dms.nix;
  overlay = wlib: final: prev: {
    dms = import ./dms.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.dms-shell;
    };
  };
}
