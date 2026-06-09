{
  package = import ./tmux.nix;
  overlay = wlib: final: prev: {
    tmux = import ./tmux.nix {
      pkgs = final;
      inherit wlib;
      basePackage = prev.tmux;
    };
  };
}
