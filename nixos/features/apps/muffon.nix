{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.muffon
  ];
}
