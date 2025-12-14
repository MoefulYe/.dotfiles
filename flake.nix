{
  description = "just dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master?shallow=1";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11?shallow=1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master?shallow=1";
    nixvim = {
      url = "github:nix-community/nixvim/main?shallow=1";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix?shallow=1";
    nur = {
      url = "github:nix-community/NUR?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils?shallow=1";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    deploy-rs.url = "github:serokell/deploy-rs";
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
      home-manager,
      ...
    }@inputs:
    let
      me = import ./me;
      helpers = import ./helpers;
      paths = rec {
        root = "${self}";
        secrets = "${root}/secrets";
        osModules = "${root}/modules/os";
        hmModules = "${root}/modules/hm";
        myPackages = "${root}/packages";
        osProfiles = "${root}/profiles/os";
        hmProfiles = "${root}/profiles/hm";
        sharedProfiles = "${root}/profiles/shared";
        myOverlays = "${root}/overlays";
        osRoles = "${root}/roles/os";
        hmRoles = "${root}/roles/hm";
        osQuirks = "${root}/quirks/os";
        hmQuirks = "${root}/quirks/hm";
	infra = "${root}/infra";
      };
      inventory = import ./inventory {
        inherit (nixpkgs) lib;
        inherit
          paths
          helpers
          me
          inventory
          ;
      };
      specialArgs = {
        inherit
          inputs
          inventory
          me
          helpers
          paths
          ;
        outputs = self;
        inherit specialArgs;
      };
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
      nixosConfigurations = helpers.mkNixosConfigs {
        inherit nixpkgs specialArgs paths;
        inherit (inventory) hosts;
      };
      darwinConfigurations = helpers.mkDarwinConfigs {
        inherit nixpkgs specialArgs paths;
        inherit (inventory) hosts;
        inherit (inputs) nix-darwin;
      };
      homeConfigurations = helpers.mkHmConfigs {
        inherit
          nixpkgs
          specialArgs
          home-manager
          paths
          ;
        inherit (inventory) users;
      };
      deploy = import ./infra/remote-deploy.nix specialArgs;
    };
}
