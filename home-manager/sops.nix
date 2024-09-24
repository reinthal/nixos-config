{
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    secrets."mail/ekonomigruppen" = {
#      owner = config.users.users.kog.name;
      path = "%r/mail/ekonomigruppen";
    };
    defaultSopsFile = ../secrets/shhh.yaml;
    age = {
      keyFile = "/home/kog/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
