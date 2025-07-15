{ ... }:
{
  sops = {
    age.keyFile = "/etc/nixos/keys.txt";
    secrets = {
      truenas = {
        sopsFile = ../../secrets/truenas.yaml;
        path = "/etc/nixos/smb-truenas";
      };
    };
  };
}
