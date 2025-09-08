{
  description = "just dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      sops-nix,
      stylix,
      nix-index-database,
      disko,
      nur,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        outputs = self;
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = import ./packages { inherit pkgs; };
        overlays = import ./overlays { inherit inputs outputs; };
        nixosConfigurations = {
          lap00-xiaoxin-mei = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs outputs; };
            modules = [
              nur.modules.nixos.default
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              ./hosts/lap00-xiaoxin-mei
            ];
          };
          desk00-u265kf-lan = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs outputs; };
            modules = [
              nur.modules.nixos.default
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              ./hosts/desk00-u265kf-lan
            ];
          };
        };
      }
    );
}
