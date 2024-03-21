{ inputs, lib, config, ... }@args:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
  cfg = config;
  appType = import ./lib/appType.nix args;
  hostSubmodule = types.submodule ({ config, ... }: {
    options = {
      _internal.apps = mkOption { type = types.listOf types.raw; };
    };
    config = {
      _internal.apps = builtins.filter
        (app: app.enablePredicate { host = config; inherit app; })
        (lib.attrValues cfg.apps);
    };
  });
in {
  options = {
    apps = mkOption {
      type = types.lazyAttrsOf appType;
      default = { };
    };

    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
    };
  };
}
