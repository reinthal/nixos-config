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

  # Open Remote - SSH (jeanp413): the open-source remote-ssh extension that
  # works on VSCodium. Microsoft's ms-vscode-remote.remote-ssh in nixpkgs is
  # proprietary and license-locked to official VS Code builds, so it's unusable
  # here. This one isn't packaged in nixpkgs, so build it from the Open VSX vsix.
  # Bump: curl -s https://open-vsx.org/api/jeanp413/open-remote-ssh/latest for
  # the version, then nix-prefetch-url the download URL and nix hash convert.
  open-remote-ssh = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "jeanp413";
      name = "open-remote-ssh";
      version = "0.5.1";
    };
    vsix = pkgs.fetchurl {
      url = "https://open-vsx.org/api/jeanp413/open-remote-ssh/0.5.1/file/jeanp413.open-remote-ssh-0.5.1.vsix";
      hash = "sha256-JBY4LGA/lJFi1cnbuh/jZ8+TcqIXa7yx+NhKWj7TZMo=";
    };
  };
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
      #   mahgnmmldchnmmdfkfcoindpgkadhhhc  ElevenReader
    };
    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };

    vscodium = {
      enable = true;
      # Declared extensions are symlinked in; mutableExtensionsDir keeps the UI
      # able to install others too. Only valid while the default profile is the
      # only profile (home-manager asserts this).
      mutableExtensionsDir = true;
      # vscode and vscodium share files (e.g. LICENSES.chromium.html), which
      # collide in the home-manager-path buildEnv. Lower vscodium's priority so
      # the conflict resolves in favour of vscode; both editors still install.
      package = lib.lowPrio pkgs.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide # Nix language support (jnoortheen)
        astral-sh.ty # ty type checker + language server (Astral)
        open-remote-ssh # Open Remote - SSH (jeanp413), defined above
      ];
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
