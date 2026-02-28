{ config, pkgs, ... }:

{
  home = { 
    enableNixpkgsReleaseCheck = false;
    username = "hit";
    homeDirectory = "/home/hit";

    packages = with pkgs;[
      tree
      zed-editor
      brave
    ];
    stateVersion = "25.11"; 
  };
}
