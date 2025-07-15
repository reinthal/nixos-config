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
        path = "${homeDirectory}/.config/Claude/kyd_githubpat.token";
        mode = "0400";
      };
      "anthropic/api_key" = {
        path = "${homeDirectory}/.config/Claude/api.key";
        mode = "0400";
      };
      "nix_cache/secret_key" = {
        path = "${homeDirectory}/.config/nix/secret.key";
        mode = "0400";
      };
      "nix_cache/nixbuilder" = {
        path = "${homeDirectory}/.aws/credentials";
        mode = "0400";
      };
      "mail/ekonomigruppen" = {
        path = "${homeDirectory}/.shhh/mail/ekonomigruppen";
        mode = "0400";
      };
    };
    defaultSopsFile = ../secrets/shhh.yaml;
    age = {
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
