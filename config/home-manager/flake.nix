{
  description = "Main Home Manager configuration for s";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sonori.url = "github:0xPD33/sonori";
  };

  outputs = { nixpkgs, home-manager, sonori, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # (Optional, but good for things like Nvidia drivers)
      };
    in {
      homeConfigurations."s" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit sonori; };
        modules = [ ./home.nix ];
      };
    };
}
