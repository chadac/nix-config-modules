{ config, lib, inputs, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
  ;
  globalDarwinModules = config.modules.darwin;

  hostsSubmodule = types.submodule ({ config, ... }: {
    options._internal.darwinModules = mkOption {
      type = types.listOf types.deferredModule;
      description = ''
        List of nix-darwin modules used by the host.

        Don't override this unless you absolutely know what you're
        doing. Prefer `host.<name>.darwin` instead.
      '';
    };
    config._internal.darwinModules =
      globalDarwinModules
      ++ (map (app: app.darwin) config._internal.apps)
      ++ [ config.darwin ];
  });
  darwinHosts = filterAttrs (_: host: host.kind == "darwin") config.hosts;
in {
  options = {
    hosts = mkOption { type = types.attrsOf hostsSubmodule; };
    darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Exported Darwin configurations, which can be used in your flake.
      '';
    };
  };
  config.darwinConfigurations = mapAttrs
    (_: host: inputs.nix-darwin.lib.darwinSystem {
      modules = host._internal.darwinModules ++ [
        { _module.args.host = host; }
      ];
    })
    darwinHosts
  ;
}
