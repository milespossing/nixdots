{
  package = import ./swaylock.nix;
  overlay = wlib: final: prev: {
    swaylock-effects = import ./swaylock.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.swaylock-effects;
    };
  };
}
