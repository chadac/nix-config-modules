{ config, lib, inputs, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
  ;
  globalNixosModules = config.modules.nixos;

  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal.nixosModules = mkOption { type = types.listOf types.deferredModule; };
    config._internal.nixosModules =
      globalNixosModules
      ++ (map (app: app.nixos) config._internal.apps)
      ++ [ config.config.nixos ];
  });
in {
  options = {
    hosts = mkOption { type = types.attrsOf hostSubmodule; };
    nixosConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };
  config.nixosConfigurations = builtins.trace config.hosts (mapAttrs
    (_: host: inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit host;
      };
      modules = host._internal.nixosModules;
    })
    config.hosts
  );
}
