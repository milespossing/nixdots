{
  package = import ./dunst.nix;
  overlay = wlib: final: prev: {
    dunst = import ./dunst.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.dunst;
    };
  };
}
