{
  inputs,
  config,
  ...
}: let
  homeDirectory = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops = {
    secrets = {
      "mail/ekonomigruppen" = {
        path = "${homeDirectory}/.shhh/mail/ekonomigruppen";
      };
    };
    defaultSopsFile = ../secrets/shhh.yaml;
    age = {
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
