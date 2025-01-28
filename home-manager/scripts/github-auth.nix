{
  pkgs,
  config,
  ...
}: let
  githubauth = pkgs.writeShellScriptBin "githubauth" ''
    echo "username=reinthal"
    echo "password=$(cat ${config.sops.secrets."github/knowyourdata/GITHUB_TOKEN".path})"
  '';
in {
  home.packages = [githubauth];
}

