{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    #    secrets."mail_bergaborgen" = {};
    defaultSopsFile = ../../secrets/shhh.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
