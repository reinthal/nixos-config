{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = ../../secrets/shhh.yaml;
  # YAML is the default
  #sops.defaultSopsFormat = "yaml";
  #sops.secrets.github_token = {
  #  format = "yaml";
  #  # can be also set per secret
  #    sopsFile = ./secrets.yaml;
  #  };
  #  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  # sops.age.generateKey = true;
  # This is the actual specification of the secrets.
    sops.secrets.example-key = {};
 # sops.secrets."mail_bergaborgen" = {};
}
