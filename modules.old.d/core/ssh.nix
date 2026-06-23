{ config, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      AllowUsers = [ config.my.username ];
    };
  };
}
