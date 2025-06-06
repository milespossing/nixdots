{ ... }:
{
  sops = {
    age.keyFile = "/etc/nixos/keys.txt";
    secrets = {
      truenas = {
        sopsFile = ../../secrets/truenass.yaml;
        path = "/etc/nixos/smb-truenas";
      };
    };
  };
}
