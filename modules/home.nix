{ config, lib, inputs, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
in {
  options = {
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
      (_: hostConfig: let
        host = hostConfig // { tags = config.defaultTags // hostConfig.tags; };
        appModules = map
          (app: app.home)
          (builtins.filter
            (app: app.enablePredicate { inherit host app; })
            (lib.attrValues config.apps));
      in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = host.pkgs;
          extraSpecialArgs = {
            inherit host;
          };
          modules = builtins.addErrorContext
            "while importing home-manager definitions"
            (config.modules.home-manager ++ appModules ++ [ host.config.home ]);
        })
      config.hosts
    ;
  };
}
