{ flake-config-lib, inputs, lib, ... }@args:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
  appType = import ./lib/appType.nix args;
in {
  options = {
    apps = mkOption {
      type = types.lazyAttrsOf appType;
      default = { };
    };
  };
}
