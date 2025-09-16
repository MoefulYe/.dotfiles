{
  description = "just dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-25-05.url = "github:nixos/nixpkgs/nixos-25.05";
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
      flake-utils,
      ...
    }@inputs:
    let
      inventory = import ./inventory;
      specialArgs = {
        inherit inputs inventory;
        outputs = self;
        paths = rec {
          root = "${self}";
          secrets = "${root}/secrets";
          osModules = "${root}/modules/os";
          hmModules = "${root}/modules/hm";
          myPackages = "${root}/packages";
          osProfiles = "${root}/profiles/os";
          hmProfiles = "${root}/profiles/hm";
          myOverlays = "${root}/overlays";
          osRoles = "${root}/roles/os";
          hmRoles = "${root}/roles/hm";
          osQuirks = "${root}/quirks/os";
          hmQuirks = "${root}/quirks/hm";
        };
      };
      inherit (inventory) nixosHosts;
      mkNixosConfigs = import ./helpers/mkNixosConfigs.nix;
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = import ./packages { inherit pkgs; };
      }
    ))
    // {
      overlays = import ./overlays { inherit inputs self; };
      nixosConfigurations = mkNixosConfigs {
        inherit nixosHosts nixpkgs specialArgs;
      };
    };
}
