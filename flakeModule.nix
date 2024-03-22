{ config, lib, inputs, flake-parts-lib, ... }: let
  inherit (lib)
    mkOption
    types
  ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
  ;
in {
  options = {
    # compatibility layer for home-manager
    flake.homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };

    nix-config = mkOption {
      type = types.submoduleWith {
        # prefix = "nix-config";
        # specialArgs = { inherit inputs; };
        modules = (import ./modules/all-modules.nix) ++ [
          {
            _module.args.inputs = inputs;
          }
        ];
      };
    };
  };

  config = {
    flake = {
      homeConfigurations = config.nix-config.homeConfigurations;
      nixosConfigurations = config.nix-config.nixosConfigurations;
    };
  };
}
