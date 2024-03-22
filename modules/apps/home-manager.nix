{ inputs, ... }:
{
  config = {
    apps.hm-single-user-integration = {
      enablePredicate = { host, ... }:
        host.tags.home-manager && host.tags.single-user;

      nixos = { host, ... }: let
        # homeModule = inputs.home-manager.nixosModules.home-manager {
        #   _file = __curPos.file;
        #   home-manager = {
        #     useGlobalPkgs = true;
        #     useUserPackages = true;
        #     extraSpecialArgs = {
        #       inherit host;
        #     };
        #     users.${host.username} = {
        #       imports = host._internal.homeModules;
        #     };
        #   };
        # };
      in {
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
