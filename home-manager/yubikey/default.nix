{pkgs, ...}
: {
  home = {
    packages = with pkgs; [
      unstable.yubikey-personalization
      unstable.yubico-piv-tool
      unstable.yubioath-flutter
      unstable.pam_u2f
    ];
  };
}
