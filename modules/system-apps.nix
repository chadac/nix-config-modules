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
  systemAppType = types.submodule {
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
      packages = mkOption {
        type = types.listOf types.str;
        description = ''
          This list of `nixpkgs` package names to generate applications for.
        '';
      };
    };
  };
  cfg = config.systemApps;
in {
  options = {
    systemApps = mkOption {
      type = types.listOf systemAppType ;
      description = lib.mdDoc ''
        A helper for instantiating packages to be installed to
        `environment.systemPackages`. On home-manager hosts this
        defaults to `home.packages`.

        ```nix
        systemApps = [{ packages = ["emacs"]; }];
        ```

        is equivalent to:

        ```nix
        apps.emacs = {
          nixos = { pkgs, ... }: {
            environment.systemPackages = [ pkgs.emacs ];
          };
          home = { host, ... }: {
            home.packages = lib.mkIf (host.kind == "home-manager") [ pkgs.emacs ];
          };
        };
        ```
      '';
    };
  };
  config = {
    apps = listToAttrs (concatLists (map
      (systemApp: map (pkg: {
        name = pkg;
        value = {
          inherit (systemApp) enable tags disableTags;
          nixos = { pkgs, ... }: {
            environment.systemPackages = [ pkgs.${pkg} ];
          };
          home = { host, pkgs, ... }: {
            home.packages = lib.mkIf (host.type == "home-manager") [ pkgs.${pkg} ];
          };
        };
      }) systemApp.packages)
      cfg
    ));
  };
}
