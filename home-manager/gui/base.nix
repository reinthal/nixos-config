{
  lib,
  pkgs,
  ...
}: let
  # Packages used for interacting with OS
  shell-packages = with pkgs; [
    hyprshot
  ];
  # Apps every GUI host gets. Chat/office apps are picked per host:
  # ./default.nix (shared hosts) or ../framebook.nix.
  desktop-apps = with pkgs;
    [
      burpsuite
      obsidian
      networkmanagerapplet
      keepassxc
      remmina
      mpv
      reaper
      # gpgme-json: native-messaging host so Mailvelope (Chromium) talks to gpg.
      # Binary lives in the `dev` output, not `out`.
      gpgme.dev
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [pkgs.spotify];
in {
  imports = [
    ./waybar.nix
    ./wayle.nix
    ./kdeconnect.nix
    ./browser.nix
  ];
  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      # NOTE: ungoogled-chromium strips Web Store / external_update_url support,
      # so declarative `extensions = [...]` never installs. Install the
      # chromium-web-store helper manually, then add these via its UI:
      #   kajibbejlbohfaggdiogboambcijhkke  Mailvelope
      #   cclelndahbckbenkjhflpdbgdldlbecc  Get cookies.txt LOCALLY
      #   fihnjjcciajhdojfnbdddfaoknhalnja  I don't care about cookies
      #   cjpalhdlnbpafiamejdnhcphjbkeiagm  uBlock Origin
      #   eimadpbcbfnmbkopoojfekhnkhdbieeh  Dark Reader
      #   mnjggcdmjocbbbhaepdhchncahnbgone  SponsorBlock
      #   nngceckbapebfimnlniiiahkandclblb  Bitwarden
      #   fcoeoabgfenejglbffodgkkbkcdhcgfn  Claude
    };
    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };

    vscodium = {
      enable = true;
      mutableExtensionsDir = true;
      # vscode and vscodium share files (e.g. LICENSES.chromium.html), which
      # collide in the home-manager-path buildEnv. Lower vscodium's priority so
      # the conflict resolves in favour of vscode; both editors still install.
      package = lib.lowPrio pkgs.vscodium;
    };
  };

  home.packages = desktop-apps;
  xdg = {
    enable = true;
    # Native-messaging host so Mailvelope (Chromium) drives gpg via gpgme-json.
    # drduh YubiKey-Guide: gpgmejson.json. Path points at the nix store binary.
    # https://drduh.github.io/YubiKey-Guide/#mailvelope
    configFile."chromium/NativeMessagingHosts/gpgmejson.json".text = builtins.toJSON {
      name = "gpgmejson";
      description = "Integration with GnuPG";
      path = "${pkgs.gpgme.dev}/bin/gpgme-json";
      type = "stdio";
      allowed_origins = [
        "chrome-extension://kajibbejlbohfaggdiogboambcijhkke/"
      ];
    };
  };
}
