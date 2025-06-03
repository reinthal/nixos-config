{pkgs, ...}
: {
  home = {
    packages = with pkgs; [
      yubikey-personalization
      yubikey-personalization-gui
      yubico-piv-tool
      yubioath-flutter
      pam_u2f
    ];
  };
}

