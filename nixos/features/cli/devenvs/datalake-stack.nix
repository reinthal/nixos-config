{config, ...}: let
  token_path = "${config.sops.secrets."github/datalakehouse/GITHUB_TOKEN".path}";
in {
  environment.sessionVariables = {
    GITHUB_TOKEN = builtins.readFile token_path;
    GITHUB_USER = "reinthal";
    GITHUB_REPO = "datalake-stack";
  };
}
