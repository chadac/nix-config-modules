{ inputs, lib, ... }@args:
let
  inherit (lib)
    filterAttrs
    mkOption
    types
  ;
  appType = import ./lib/appType.nix args;

  mkModuleOption = description: mkOption {
    type = types.deferredModule;
    default = { };
    inherit description;
  };

  hostType = types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      kind = mkOption {
        type = types.enum [ "nixos" "home-manager" ];
      };
      system = mkOption {
        type = types.str;
        default = null;
      };
      config = mkOption {
        type = types.submodule {
          options = {
            nixpkgs = mkModuleOption "nixpkgs configurations";
            nixos = mkModuleOption "NixOS configurations";
            home = mkModuleOption "home-manager configurations";
          };
        };
        default = { };
      };
    };

    config = {
      inherit name;
    };
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf hostType;
      default = { };
    };
  };
}
