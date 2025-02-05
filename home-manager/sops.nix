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
      "github/knowyourdata/GITHUB_TOKEN" = {
        path = "${homeDirectory}/.shhh/github/knowyourdata/GITHUB_TOKEN";
      };
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
