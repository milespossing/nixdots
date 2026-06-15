{
  package = import ./kitty.nix;
  overlay = wlib: final: prev: {
    kitty = import ./kitty.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.kitty;
    };
  };
}
