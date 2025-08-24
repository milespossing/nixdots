{
  inputs,
  ...
}:
{
  imports = [ inputs.my-nixcats.homeModules.default ];
  nixcats-full = {
    enable = true;
  };
}
