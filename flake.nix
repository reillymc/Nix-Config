{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    docs = {
      url = "path:./docs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      agenix,
      docs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # List of NixOS hosts. Each host name must match the corresponding folder in `hosts/`
      hosts = [
        # "example" # Example host, can be removed or replaced
        "terra"
        "slate"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit hostname;
            inherit nixpkgs-unstable;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.default
            agenix.nixosModules.default
          ];
        }
      );

      packages.${system} = {
        docs = docs.packages.${system}.docs;
      };
    };
}
