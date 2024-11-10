{pkgs, ...}: {
  nix.extraOptions = ''
    trusted-users = root kog
  '';
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    devenv
  ];
}

