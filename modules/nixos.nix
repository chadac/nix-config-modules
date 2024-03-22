{ config, lib, inputs, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
  ;
  globalNixosModules = config.modules.nixos;

  hostSubmodule = types.submodule ({ config, ... }: {
    options._internal.nixosModules = mkOption {
      type = types.listOf types.deferredModule;
      description = ''
        List of NixOS modules used by the host.

        Don't override this unless you absolutely know what you're doing. Prefer
        using `host.<name>.nixos` instead.
      '';
    };
    config._internal.nixosModules =
      globalNixosModules
      ++ (map (app: app.nixos) config._internal.apps)
      ++ [ config.nixos ];
  });

  nixosHosts = filterAttrs (_: host: host.kind == "nixos") config.hosts;
in {
  options = {
    hosts = mkOption { type = types.attrsOf hostSubmodule; };
    nixosConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Exported NixOS configurations, which can be used in your flake.
      '';
    };
  };
  config.nixosConfigurations = mapAttrs
    (_: host: inputs.nixpkgs.lib.nixosSystem {
      modules = host._internal.nixosModules ++ [
        {
          _module.args.host = host;
          nixpkgs.pkgs = host._internal.pkgs;
        }
      ];
    })
    nixosHosts
  ;
}
