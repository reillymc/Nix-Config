{
  description = "NixOS and Home Manager module documentation in Markdown";

  # will be overridden by main flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      system = builtins.currentSystem or "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # --- NixOS modules ---
      nixosEval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        inherit system;
        baseModules = [ ../modules/nixos ];
        modules = [ ];
        check = false;
      };

      nixosDocs = pkgs.nixosOptionsDoc {
        inherit (nixosEval) options;
      };

      # --- Home Manager modules ---
      hmLib = import (home-manager + "/modules/lib/stdlib-extended.nix") nixpkgs.lib;

      hmEval = hmLib.evalModules {
        modules = [ ../modules/home-manager ];
        specialArgs = {
          inherit pkgs;
          configDir = "/fake/configDir"; # dummy path for docgen
        };
        check = false;
      };

      hmDocs = pkgs.nixosOptionsDoc {
        inherit (hmEval) options;
      };

      nixosDocsHeader = ''
        # NixOS Modules Options
      '';
      homeManagerDocsHeader = ''
        # Home Manager Modules Options
      '';

    in
    {
      packages.${system} = {
        # Generate separate Markdown files with nested headings
        nixos-docs = pkgs.runCommand "nixos-options-doc" { } ''
          mkdir -p $out
          echo "${nixosDocsHeader}" > $out/nixos-options.md
          # Use the extracted options content (CommonMark)
          cat ${nixosDocs.optionsCommonMark} >> $out/nixos-options.md
          cat ${nixosDocs.optionsJSON}/share/doc/nixos/options.json >> $out/nixos-options.json
        '';

        home-docs = pkgs.runCommand "home-options-doc" { } ''
          mkdir -p $out
          echo "${homeManagerDocsHeader}" > $out/home-options.md
          # Use the extracted options content (CommonMark)
          cat ${hmDocs.optionsCommonMark} >> $out/home-options.md
          cat ${hmDocs.optionsJSON}/share/doc/nixos/options.json >> $out/home-options.json
        '';

        docs = pkgs.runCommand "all-docs" { } ''
          mkdir -p $out
          cp ${self.packages.${system}.nixos-docs}/nixos-options.md $out/
          cp ${self.packages.${system}.home-docs}/home-options.md $out/
          cp ${self.packages.${system}.nixos-docs}/nixos-options.json $out/
          cp ${self.packages.${system}.home-docs}/home-options.json $out/
        '';
      };

      # Default package is just both docs available
      defaultPackage.${system} = self.packages.${system}.docs;
    };
}
