{
  # Opt-in: hosts that need the proton wireguard tunnel import `wireguard`.
  flake.modules.nixos.wireguard =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.wireguard-tools ];
      networking.wireguard.enable = true;

      sops.secrets.wireguard-il = {
        sopsFile = ../../secrets/wireguard.yaml;
        path = "/etc/wireguard/proton-il.conf";
        key = "us-il-115";
      };
    };
}
