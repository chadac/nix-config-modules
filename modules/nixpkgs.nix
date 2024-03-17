{ inputs, lib, config, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
  nixpkgsModule = { host, ... }: {
    _file = __curPos.file;

    options = {
      system = mkOption {
        type = types.str;
      };
      overlays = mkOption {
        type = types.listOf (types.functionTo (types.functionTo types.pkgs));
        default = [ ];
      };
    };

    config = {
      system = host.system;
    };
  };
  cfg = config;
  globalModules = config.modules.nixpkgs;
in {
  options.hosts = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      options.pkgs = mkOption {
        type = types.pkgs;
      };

      config.pkgs = let
        host = config // { tags = cfg.defaultTags // config.tags; };
        appModules = map
          (app: app.nixpkgs)
          (builtins.filter
            (app: app.enablePredicate { inherit host app; })
            (lib.attrValues cfg.apps));
        nixParams = lib.evalModules {
          specialArgs = {
            inherit host;
          };
          modules = builtins.addErrorContext
            "while evaluating modules for nixpkgs on host '${host.name}'"
            (globalModules ++ appModules ++ [ host.config.nixpkgs ]);
        };
      in import inputs.nixpkgs nixParams.config;
    }));
  };

  config.modules.nixpkgs = [ nixpkgsModule ];
}
