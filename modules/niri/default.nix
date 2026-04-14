{
  package = import ./niri.nix;
  overlay =
    wlib:
    {
      extraConfig ? "",
    }:
    final: prev: {
      niri-configured = import ./niri.nix {
        pkgs = final;
        inherit wlib extraConfig;
        basePackage = prev.niri;
      };
    };
}
