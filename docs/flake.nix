{
  description = "NixOS and Home Manager module documentation in Markdown";

  # will be overridden by main flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (nixpkgs) lib;

      # Flake source root (the repo; docs/ is a subdirectory).
      repoRoot = toString ../.;
      repoPrefix = "${repoRoot}/";

      # Link options to files in this repo with paths relative to docs/
      relativizeDecl =
        decl:
        if (lib.isString decl || lib.isPath decl) && lib.hasPrefix repoPrefix (toString decl) then
          let
            rel = lib.removePrefix repoPrefix (toString decl);
          in
          {
            name = rel;
            url = "../${rel}";
          }
        else
          decl;

      transformOptions =
        opt:
        opt
        // {
          declarations = map relativizeDecl opt.declarations;
        }
        // lib.optionalAttrs (lib.hasPrefix "_module" opt.name) {
          internal = true;
        };

      # --- NixOS modules ---
      nixosEval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        inherit system;
        baseModules = [ ../modules/nixos ];
        modules = [
          { _module.check = false; }
        ];
      };

      nixosDocs = pkgs.nixosOptionsDoc {
        inherit (nixosEval) options;
        inherit transformOptions;
      };

      # --- Home Manager modules ---
      hmLib = import (home-manager + "/modules/lib/stdlib-extended.nix") nixpkgs.lib;

      hmEval = hmLib.evalModules {
        modules = [
          ../modules/home-manager
          { _module.check = false; }
        ];
        specialArgs = {
          inherit pkgs;
          theme = "dark";
        };
      };

      hmDocs = pkgs.nixosOptionsDoc {
        inherit (hmEval) options;
        inherit transformOptions;
      };

      mkDoc =
        title: body:
        pkgs.concatText "options.md" [
          (pkgs.writeText "title.md" "# ${title}\n\n")
          body
        ];

    in
    {
      # cp so regenerated docs are regular files, not store symlinks.
      packages.${system}.docs = pkgs.runCommand "docs" { } ''
        mkdir -p $out
        cp ${mkDoc "NixOS Configuration Options" nixosDocs.optionsCommonMark} $out/nixos-options.md
        cp ${mkDoc "Home Manager Configuration Options" hmDocs.optionsCommonMark} $out/home-options.md
      '';
    };
}
