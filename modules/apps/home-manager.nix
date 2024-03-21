{ inputs, ... }:
{
  apps.hm-single-user-integration = {
    enablePredicate = { host, app, ... }:
      host.tags.home-manager && host.tags.single-user;

    nixos = { host, ... }: let
      homeModule = inputs.home-manager.nixosModules.home-manager {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit host;
          };
          users.${host.username} = {
            imports = host.modules.home;
          };
        };
      };
    in {
      imports = [ homeModule ];
    };
  };

  defaultTags.home-manager = true;
}
