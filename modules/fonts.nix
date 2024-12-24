{ pkgs, ... }:
{
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
        departure-mono
        font-awesome
        hack-font
        material-design-icons
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        (nerdfonts.override { fonts = [
          "JetBrainsMono"
          "FiraCode"
          "DroidSansMono"
          "Noto"];})
    ];

    fonts.fontDir.enable = true;
}
