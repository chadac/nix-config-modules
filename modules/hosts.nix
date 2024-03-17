{ inputs, lib, config, ... }@args:
let
  inherit (lib)
    filterAttrs
    mkOption
    types
  ;
  appType = import ./lib/appType.nix args;

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
        type = appType;
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
