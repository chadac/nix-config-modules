{ inputs, lib, config, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;

  globalNixPkgsModules = config.modules.nixpkgs;

  rootModule = { host, ... }: {
    _file = __curPos.file;

    options = {
      system = mkOption {
        type = types.str;
      };
      overlays = mkOption {
        type = types.listOf (types.functionTo (types.functionTo types.pkgs));
        default = [ ];
      };
      config = mkOption {
        type = types.submodule {
          options = {
            allowUnfree = mkOption { type = types.bool; default = true; };
            allowUnfreePackages = mkOption { type = types.listOf types.str; default = [ ];};
            allowUnfreePredicate = mkOption { type = types.functionTo types.bool; };
          };
        };
      };
    };

    config = {
      system = lib.mkDefault host.system;
      config.allowUnfreePredicate = pkg:
        builtins.any 
    };
  };
  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal = {
      nixPkgsModules = mkOption { type = types.listOf types.deferredModule; };
      pkgs = mkOption { type = types.pkgs; };
    };
    config._internal = let
      appModules = map (app: app.nixpkgs) config._internal.apps;
      host = config;
      nixParams = lib.evalModules {
        specialArgs = {
          inherit host;
        };
        modules = host._internal.nixPkgsModules;
      };
     in {
       nixPkgsModules = globalNixPkgsModules ++ appModules ++ [ config.config.nixpkgs ];
       pkgs = import inputs.nixpkgs nixParams.config;
     };
  });
  cfg = config;
in {
  options.hosts = mkOption {
    type = types.attrsOf hostSubmodule;
  };

  config.modules.nixpkgs = [ rootModule ];
}
