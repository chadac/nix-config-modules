{ pkgs, nix-config }: let
  inherit (pkgs) lib;
  appDetails= lib.mapAttrs (appName: app: {
    inherit (app) description tags disableTags systems;
    name = appName;
  }) nix-config.apps;
  hostDetails = lib.mapAttrs (hostname: host: {
    inherit (host) name kind system;
    tags = lib.attrNames
      (lib.filterAttrs (tag: enabled: enabled) host.tags);
    apps = map (app: app.name) host._internal.apps;
  }) nix-config.hosts;
  appJson = pkgs.writeText "apps.json" (builtins.toJSON appDetails);
  hostJson = pkgs.writeText "hosts.json" (builtins.toJSON hostDetails);
  python-env = pkgs.python3.withPackages(p: with p; [
    rich
  ]);
in {
  describe-hosts = pkgs.writeShellScriptBin "describe-hosts" ''
    ${python-env}/bin/python ${./describe_hosts.py} ${hostJson}
  '';
  describe-apps = pkgs.writeShellScriptBin "describe-apps" ''
    ${python-env}/bin/python ${./describe_apps.py} ${appJson}
  '';
}
