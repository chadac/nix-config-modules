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
      darwin = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Additional global modules to add to each nix-darwin configuration.
        '';
      };
      nixos = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Additional global modules to add to each NixOS configuration. Useful
          for extending NixOS in the standard fashion.
        '';
      };
      home-manager = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Additional global modules to add to each Home Manager configuration.
          Useful for extending Home Manager in the standard fashion.
        '';
      };
      nixpkgs = mkOption {
        type = types.listOf types.deferredModule;
        default = [ ];
        description = ''
          Additional global modules to add to each nixpkgs instantiation. Useful
          if we missed some option for configuring `nixpkgs`, which is bound to
          happen cause that shit's distributed everywhere.
        '';
      };
    };
  };
}
