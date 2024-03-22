# We need some home-manager integrations for users on NixOS
# systems. This is optionally enabled when you want to use
# home-manger.
{ inputs, ... }:
{
  config = {
    apps.hm-single-user-integration = {
      enablePredicate = { host, ... }:
        host.tags.home-manager && host.tags.single-user;

      nixos = { host, ... }: {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit host;
          };
          users.${host.username} = {
            imports = host._internal.homeModules;
          };
        };
      };
    };

    defaultTags.home-manager = true;
  };
}
