{
  package = import ./rofi.nix;
  overlay = wlib: final: prev: {
    rofi = import ./rofi.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.rofi;
    };
  };
}
