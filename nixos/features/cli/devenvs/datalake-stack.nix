{
  config,
  ...
}: let
  token_path = "${config.sops.secrets."github/datalake-stack/GITHUB_TOKEN".path}";
in {
  # Use sops-secrets to define environment variables
  environment.variables = {
    GITHUB_TOKEN = builtins.readFile token_path;
    GITHUB_USER = "reinthal";
    GITHUB_REPO = "datalake-stack";
  };
}
