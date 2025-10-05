{
  services.syncthing = {
    enable = true;
    group = "users";
    user = "kog";
    dataDir = "/home/kog/Documents";
    configDir = "/home/kog/Documents/.config/syncthing";
  };
}
