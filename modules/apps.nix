{ inputs, lib, config, moduleType, ... }@args:
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
      _internal.apps = mkOption {
        type = types.listOf types.raw;
        description = ''
          The list of apps enabled for this host, containing deferred modules
          for initializing later module systems. This is used internally to
          track per-host app configurations, since each host will enable its own
          set of apps.

          Do not specify or override this attribute unless you know what you're
          doing! Use `host.<name>.nix-config` instead.
        '';
      };
    };
    config = let
      apps = (lib.evalModules {
        modules = moduleType.getSubModules ++ [
          config.nix-config
          { _module.args.host = config; }
        ];
      }).config.apps;
    in {
      _internal.apps = builtins.filter
        (app: app.enablePredicate { host = config; inherit app; })
        (lib.attrValues apps);
    };
  });
in {
  options = {
    apps = mkOption {
      type = types.lazyAttrsOf appType;
      default = { };
      description = lib.mdDoc ''
        An app is an individual module that defines collective configurations
        for generally a single application across NixOS/home-manager/nixpkgs.
        Each host defines the *set* of apps that it wishes to initialize.
      '';
      example = ''
        apps.emacs = {
          tags = [ "development" ];
          nixos = {
            services.emacs.enable = true;
          };
          home = { pkgs, ... }: {
            programs.emacs = {
              enable = true;
              package = pkgs.emacsUnstable;
            };
          };
          nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
        };
      '';
    };

    hosts = mkOption {
      type = types.attrsOf hostSubmodule;
    };
  };

  config = {
    _module.args.host = lib.mkDefault { };
  };
}
