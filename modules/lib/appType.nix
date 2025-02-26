{ lib, ... }:
let
  inherit (lib)
    attrValues
    listToAttrs
    mkOption
    types
  ;

in types.submodule {
  _file = __curPos.file;

  options = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        If set, enables or disables the given app. This overrides tag behavior.
      '';
    };
    tags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of tags that, when supplied, will enable the given app on the given host.
      '';
    };
    disableTags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of tags that will disable the app.
      '';
    };
    systems = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      description = ''
        If set, this application will only be available on the given systems.

        This overrides `enable`.
      '';
    };
    enablePredicate = mkOption {
      type = types.functionTo types.bool;
      default = { host, app, ... }:
        (
          if (app.enable != null) then app.enable
          else if (app.tags == [ ]) then true
          else (
            (builtins.any (tag: host.tags.${tag} or (throw "tag does not exist: '${tag}'")) app.tags)
            && !(builtins.any (tag: host.tags.${tag} or (throw "tag does not exist: '${tag}'")) app.disableTags)
          )
        ) && (app.systems == null || (builtins.elem host.system app.systems))
      ;
      description = lib.mdDoc ''
        Predicate used to determine if the given app should be enabled on the given host.

        It's recommended not to override this function, as its default behavior
        incorporates forceEnable, tags and disableTags.
      '';
    };
    darwin = mkOption {
      type = types.deferredModule;
      default = { };
      description = lib.mdDoc ''
        `nix-darwin` configurations. See the [nix-darwin manual](https://daiderd.com/nix-darwin/manual/index.html)
         for more information.
      '';
    };
    home = mkOption {
      type = types.deferredModule;
      default = { };
      description = lib.mdDoc ''
        `home-manager` configurations. See the [home-manager manual](https://nix-community.github.io/home-manager/)
         for more information.
      '';
    };
    nixos = mkOption {
      type = types.deferredModule;
      default = { };
      description = lib.mdDoc ''
        NixOS configurations. See the [NixOS manual](https://nixos.org/manual/nixos/stable/#ch-configuration)
        for more information.
      '';
    };
    nixpkgs = mkOption {
      type = types.deferredModule;
      default = { };
      description = lib.mdDoc ''
        Nixpkgs configurations. See `./modules/nixpkgs.nix` for more details.
      '';
    };
  };
}
