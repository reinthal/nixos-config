{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    secrets.nas = {
      owner = config.users.users.kog.name;
    };
    secrets."mail/ekonomigruppen" = {
      owner = config.users.users.kog.name;
    };
    defaultSopsFile = ../../secrets/shhh.yaml;
    age = {
      keyFile = "/home/kog/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
