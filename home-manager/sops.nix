{
  inputs,
  config,
  secretsFile ? ../secrets/shhh.yaml,
  ...
}: let
  homeDirectory = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    secrets = {
      "yt-dlp" = {
        path = "${homeDirectory}/.config/yt-dlp.txt";
        mode = "0400";
      };
      "apple/icloud_username" = {};
      "apple/icloud_password" = {};

      "gcalendar/client_id" = {};
      "gcalendar/client_secret" = {};
    };
    defaultSopsFile = secretsFile;
    age = {
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
