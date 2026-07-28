{pkgs, ...}: {
  nix.extraOptions = ''
    trusted-users = root kog
  '';
  environment.systemPackages = with pkgs; [
    devenv
    borgbackup
  ];
}
