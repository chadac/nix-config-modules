{
  description = "Modules for managing system configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      ./tests/multi-user.nix
    ];

    flake.flakeModule = import ./flakeModule.nix;
    systems = import inputs.systems;
    perSystem = { pkgs, lib, ... }: let
      eval = lib.evalModules {
        modules = import ./modules/all-modules.nix;
      };
    in {
      packages.docs = (pkgs.nixosOptionsDoc {
        options = eval.options;
      }).optionsAsciiDoc;
    };
  };
}
