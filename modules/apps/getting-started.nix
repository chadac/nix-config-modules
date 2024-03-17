{ ... }: {
  apps.getting-started = {
    tags = ["getting-started"];
    home = {
      home.stateVersion = "23.11";
    };
  };

  defaultTags = {
    getting-started = false;
  };
}
