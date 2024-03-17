{
  apps.host-config = {
    tags = [ "defaults" ];
    home = { host, ... }: {
      home.username = host.username;
    };
  };
  defaultTags = {
    defaults = true;
  };
}
