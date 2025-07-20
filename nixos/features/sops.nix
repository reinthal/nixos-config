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
    };
    defaultSopsFile = ../../secrets/shhh.yaml;
    age = {
      keyFile = "/home/kog/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
