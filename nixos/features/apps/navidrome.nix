{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.navidrome
  ];
}
