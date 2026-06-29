{
  flake.modules.homeManager.protonmail =
    { ... }:
    {
      services.protonmail-bridge.enable = true;
    };
}
