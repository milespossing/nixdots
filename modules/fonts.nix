{ pkgs, ... }:
{
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        font-awesome
        material-design-icons
        hack-font
        (nerdfonts.override { fonts = [
          "JetBrainsMono"
          "FiraCode"
          "DroidSansMono"
          "Noto"
        ];})
    ];

    fonts.fontDir.enable = true;
}
