{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alacritty # optional, used for typing chinese font
    starship
  ];

  programs.starship = {
    enable = true;
    presets = [ "gruvbox-rainbow" ];
  };
}
