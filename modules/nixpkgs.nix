{ inputs, lib, config, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;

  globalNixPkgsModules = config.modules.nixpkgs;

  rootModule = { host, config, ... }: {
    _file = __curPos.file;

    options = {
      params = mkOption {
        type = types.submodule {
          options = {
            system = mkOption {
              type = types.str;
            };
            overlays = mkOption {
              type = types.listOf types.raw;
              default = [ ];
            };
            config = mkOption {
              type = types.submodule (import "${inputs.nixpkgs}/pkgs/top-level/config.nix");
              default = { };
            };
          };
        };
        default = { };
      };
    };

    config = {
      params.system = lib.mkDefault host.system;
    };
  };

  predicateModule = { config, ... }: {
    _file = __curPos.file;
    options = {
      packages = mkOption {
        type = types.submodule {
          options = {
            unfree = mkOption { type = types.listOf types.str; default = [ ]; };
            insecure = mkOption { type = types.listOf types.str; default = [ ]; };
          };
        };
        default = {};
      };
    };

    # Map packages.unfree/insecure to the new nixpkgs config options
    config = {
      params.config.allowUnfreePackages = config.packages.unfree;
      params.config.permittedInsecurePackages = config.packages.insecure;
    };
  };

  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal = {
      nixPkgsModules = mkOption {
        type = types.listOf types.deferredModule;
        description = ''
          List of nixpkgs modules used to instantiate the host.

          Don't override this unless you absolutely know what you're doing. Prefer
          using `host.<name>.nixpkgs` instead.
        '';
      };
      pkgs = mkOption {
        type = types.pkgs;
        description = lib.mdDoc ''
          The import of `nixpkgs` used by this host.

          Generally you shouldn't override this, and instead customize
          `nixpkgs` using `host.<name>.nixpkgs` instead.
        '';
      };
    };
    config._internal = let
      appModules = map (app: app.nixpkgs) config._internal.apps;
      host = builtins.removeAttrs config [ "_internal" "nix-config" ];
      nixPkgsModules = globalNixPkgsModules ++ appModules ++ [ config.nixpkgs ];
      nixParams = (lib.evalModules {
        modules = nixPkgsModules ++ [
          {
            _module.args = {
              inherit host;
              inputs = builtins.removeAttrs inputs [ "self" "nixpkgs" ];
            };
          }
        ];
      }).config;
     in {
       inherit nixPkgsModules;
       pkgs = import inputs.nixpkgs nixParams.params;
     };
  });
  cfg = config;
in {
  options.hosts = mkOption {
    type = types.attrsOf hostSubmodule;
  };

  config.modules.nixpkgs = [ rootModule predicateModule ];
}
