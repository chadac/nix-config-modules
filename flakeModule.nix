{ config, lib, inputs, flake-parts-lib, ... }: let
  inherit (lib)
    mkOption
    types
  ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
  ;
  defaultSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

in {
  options = {
    # compatibility layer for home-manager
    flake.homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };

    nix-config = mkOption {
      type = types.submoduleWith {
        modules = (import ./modules/all-modules.nix) ++ [
          { _module.args.inputs = inputs; }
        ];
      };
    };
  };

  config = {
    systems = lib.mkDefault defaultSystems;
    perSystem = { pkgs, ... }: {
      packages = import ./tools { inherit pkgs; inherit (config) nix-config; };
    };
    flake = {
      darwinConfigurations = config.nix-config.darwinConfigurations;
      homeConfigurations = config.nix-config.homeConfigurations;
      nixosConfigurations =  config.nix-config.nixosConfigurations;
    };
  };
}
