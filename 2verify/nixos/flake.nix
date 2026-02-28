{
  description = "Entry of NixOS flake";
 
  inputs = {
    nixpkgs.url = "https://nixos.org/channels/nixos-25.11/nixexprs.tar.xz";
    #nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable/nixexprs.tar.xz";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:

    let
      system = "x86_64-linux";
      #pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      overlay-unstable = final: prev: {
        # unstable = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
        # use this variant if unfree packages are needed
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };
    in { 
      nixosConfigurations.nixup = nixpkgs.lib.nixosSystem {
        # specialArgs or _module.args
        specialArgs = { inherit inputs; }; # or { inherit pkgs-unstable; inherit inputs; };
        modules = [
          # Overlay-module makes "pkgs.stable" available in configurations
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./configuration.nix 
          ./graphic/cosmic.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hit = import ./home/hit.nix;
          }
        ];
      };
    };
}
