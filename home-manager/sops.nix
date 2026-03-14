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
      "nix_cache/secret_key" = {
        path = "${homeDirectory}/.config/nix/secret.key";
        mode = "0400";
      };
      "nix_cache/nixbuilder" = {
        path = "${homeDirectory}/.aws/credentials";
        mode = "0400";
      };
      "yt-dlp" = {
        path = "${homeDirectory}/.config/yt-dlp.txt";
        mode = "0400";
      };
      "apple/icloud_username" = {};
      "apple/icloud_password" = {};
      "protonmail/bridge_pw" = {};
      "protonmail/username" = {};
    };
    defaultSopsFile = secretsFile;
    age = {
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
