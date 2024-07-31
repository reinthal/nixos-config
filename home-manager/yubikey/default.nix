{pkgs, ...}
: {
    home = {
        stateVersion = "24.05";
        # specify my home-manager configs
        packages = with pkgs; 
        [
            yubikey-manager
            yubikey-manager-qt
            yubikey-personalization
            yubikey-personalization-gui
            yubico-piv-tool
            yubioath-flutter
        ];
    };
}
    