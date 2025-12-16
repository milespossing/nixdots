{
  inputs,
  ...
}:
{
  imports = [ inputs.my-nixcats.nixosModules.default ];
  nixcats-full = {
    enable = true;
  };
}
