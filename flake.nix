{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
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
      home-manager,
      docs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # List of NixOS hosts. Each host name must match the corresponding folder in `hosts/`
      hosts = [
        # "example" # Example host, can be removed or replaced
        "terra"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit hostname;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.default
          ];
        }
      );

      packages.${system} = {
        docs = docs.packages.${system}.docs;
      };
    };
}
