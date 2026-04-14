{
  package = import ./swayidle.nix;
  overlay = wlib: final: prev: {
    swayidle = import ./swayidle.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.swayidle;
    };
  };
}
