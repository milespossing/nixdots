{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Tools
    (azure-cli.withExtensions [
      azure-cli.extensions.azure-devops
    ])
  ];
}
