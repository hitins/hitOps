{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
    ];
  };

  fonts = {
    packages = with pkgs; [
      source-code-pro
      source-han-sans
      source-han-serif
      nerd-fonts.sauce-code-pro
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "SauceCodePro Nerd Font Mono" ];
        sansSerif = [ "Source Han Sans SC" ];
        serif = [ "Source Han Serif SC" ];
      };
    };
  };
}
