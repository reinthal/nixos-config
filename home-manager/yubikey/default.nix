{pkgs, ...}
: {
  home = {
    packages = with pkgs; [
      yubikey-manager
      yubikey-manager-qt
      yubikey-personalization
      yubikey-personalization-gui
      yubico-piv-tool
      yubioath-flutter
    ];
  };
}

