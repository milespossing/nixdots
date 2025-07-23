{ ... }:
{
  sops = {
    age.keyFile = "/etc/nixos/keys.txt";
    secrets = {
      truenas = {
        sopsFile = ../../secrets/general.yaml;
        path = "/etc/nixos/smb-truenas";
      };
      wireguard-il = {
        sopsFile = ../../secrets/wireguard.yaml;
        path = "/etc/wireguard/proton-il.conf";
        key = "us-il-115";
      };
    };
  };
}
