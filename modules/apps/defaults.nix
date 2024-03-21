{
  apps.host-config = {
    tags = [ "defaults" ];
    nixos = { host, pkgs, ... }: {
      nixpkgs.pkgs = pkgs;
    };
    home = { host, ... }: {
      home.username = host.username;
    };
  };
  defaultTags = {
    defaults = true;
  };
}
