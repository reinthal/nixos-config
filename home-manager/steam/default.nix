{
  pkgs,
  inputs,
  stateVersion,
  ...
}: {
  home = {
    stateVersion = stateVersion;
    packages = with pkgs; [
      # cli
      steam
    ];
  };
}
