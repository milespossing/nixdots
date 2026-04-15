{
  mkOverlay =
    wlib:
    {
      name ? "niri-configured",
      displayName ? "Niri",
      barCommand ? null,
      extraConfig ? "",
    }:
    final: prev: {
      ${name} = import ./niri.nix (
        {
          pkgs = final;
          inherit
            wlib
            name
            displayName
            extraConfig
            ;
          basePackage = prev.niri;
        }
        // (if barCommand != null then { barCommand = barCommand final; } else { })
      );
    };
}
