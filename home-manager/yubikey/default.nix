{pkgs, ...}
: {
  home = {
    packages = with pkgs; [
      yubikey-personalization
      yubico-piv-tool
      yubioath-flutter
      pam_u2f
    ];
  };
}
