{ self, pkgs, nixpkgs, ... }@inputs:

{
  imports = [
    ./font_i18n.nix
    ./shell.nix
  ];

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = false;
  };

  environment.cosmic.excludePackages = with pkgs; [
    adwaita-icon-theme
    alsa-utils
    cosmic-edit
    cosmic-player
    cosmic-store
    hicolor-icon-theme
    networkmanagerapplet
    pop-icon-theme
  ];
}
