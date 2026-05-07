{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    secrets = {
      "meilisearch/master_key".neededForUsers = true;
      nas = {
        owner = config.users.users.kog.name;
      };
      "s3/client_id" = {
        owner = config.users.users.kog.name;
      };
      "s3/secret_key" = {
        owner = config.users.users.kog.name;
      };
      "nix_cache/secret_key" = {
        path = "/etc/nix/signing-key.sec";
        mode = "0400";
      };
    };
    defaultSopsFile = ../../secrets/shhh.yaml;
    age = {
      keyFile = "/home/kog/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
