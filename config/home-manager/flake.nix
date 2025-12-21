{
  description = "Main Home Manager configuration for s";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    sonori.url = "github:0xPD33/sonori"; # <--- The new name
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."s" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # [UPDATE ARG HERE TOO]
        extraSpecialArgs = {
          inherit inputs;
          inherit (inputs) sonori;

        };

        modules = [ ./home.nix ];
      };
    };
}
