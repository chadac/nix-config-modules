# Shorthand for adding packages that are just putting stuff in the
# home config.
{ lib, config, ... }:
let
  inherit (lib)
    concatLists
    listToAttrs
    mkOption
    types
  ;
  homeAppType = types.submodule {
    options = {
      enable = mkOption {
        type = types.nullOr types.bool;
        description = ''
          App attribute passed to all generated applications.
        '';
        default = null;
      };
      tags = mkOption {
        type = types.listOf types.str;
        description = ''
          App attribute passed to all generated applications.
        '';
      };
      disableTags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          App attribute passed to all generated applications.
        '';
      };
      systems = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = ''
          App attribute passed to all generated applications.
        '';
      };
      packages = mkOption {
        type = types.listOf types.str;
        description = ''
          This list of `nixpkgs` package names to generate applications for.
        '';
      };
    };
  };
  cfg = config.homeApps;
in {
  options = {
    homeApps = mkOption {
      type = types.listOf homeAppType;
      description = lib.mdDoc ''
        A helper for instantiating applications that only add a package to
        `home.packages`. This generates a single application per package, so
        for example:

            homeApps = [{ packages = ["emacs"]; }];

        is equivalent to:

            apps.emacs = {
              home = { pkgs, ... }: {
                home.packages = [ pkgs.emacs ];
              };
            };
      '';
    };
  };
  config = {
    apps = listToAttrs (concatLists (map
      (homeApp: map (pkg: {
        name = pkg;
        value = {
          inherit (homeApp) enable tags systems disableTags;
          home = { pkgs, ... }: {
            home.packages = [ pkgs.${pkg} ];
          };
        };
      }) homeApp.packages)
      cfg
    ));
  };
}
