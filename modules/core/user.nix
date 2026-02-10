{ pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.bash;
  users.users.miles = {
    isNormalUser = true;
    description = "miles";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
