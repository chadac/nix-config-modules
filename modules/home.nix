{ config, lib, inputs, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
  globalHomeModules = config.modules.home-manager;

  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal.homeModules = mkOption { type = types.listOf types.deferredModule; };
    config._internal.homeModules =
      globalHomeModules
      ++ (map (app: app.home) config._internal.apps)
      ++ [ config.config.home ];
  });
in {
  options = {
    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
    };

    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Home configurations. Instantiated by home-manager build.
      '';
    };
  };

  config = {
    homeConfigurations = mapAttrs
      (_: host:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = host._internal.pkgs;
          extraSpecialArgs = {
            inherit host;
          };
          modules = builtins.addErrorContext
            "while importing home-manager definitions"
            host._internal.homeModules;
        })
      config.hosts
    ;
  };
}
