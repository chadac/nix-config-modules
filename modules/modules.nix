{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;
in
{
  options = {
    modules = {
      nixos = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };
      home-manager = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };
      nixpkgs = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
      };
    };
  };
}
