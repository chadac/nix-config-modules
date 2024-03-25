{ config, lib, inputs, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
  ;
  globalHomeModules = config.modules.home-manager;

  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal.homeModules = mkOption {
      type = types.listOf types.deferredModule;
      description = ''
        Internal list of home-manager modules passed to the host.

        Don't override this unless you absolutely know what you're doing. Prefer
        using `host.<name>.home` instead.
      '';
    };
    config._internal.homeModules =
      globalHomeModules
      ++ (map (app: app.home) config._internal.apps)
      ++ [ config.home ];
  });

  # include everything because sometimes we want to just apply HM
  # profiles locally on NixOS
  homeHosts = config.hosts;
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
      homeHosts
    ;
  };
}
