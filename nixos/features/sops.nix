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
      "github/datalakehouse/GITHUB_TOKEN" = {
        owner = config.users.users.kog.name;
      };

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
