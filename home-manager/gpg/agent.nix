# gpg-agent run by home-manager, following drduh's YubiKey-Guide:
# https://drduh.github.io/YubiKey-Guide/#configure-gpg-agent
#
# The private keys live only on the YubiKeys. This machine holds the public
# key (imported below, ultimately trusted) plus secret-key *stubs* that point
# gpg at the card. The stubs are created once per machine by reading the card:
#
#   gpg --card-status          # with a YubiKey inserted
#   gpg -K                     # keys now show `ssb>` (stub on card)
#
# To swap to the other YubiKey later, run `yswitch` (scripts/switch-keys.nix).
#
# Used on hosts whose NixOS config leaves programs.gnupg.agent off (framebook).
{pkgs, ...}: {
  programs.gpg = {
    # drduh: "Import the public key ... and set ultimate trust."
    # Assembled from keys.openpgp.org (current subkey expiry) + keyserver.ubuntu.com
    # (user ID). Refresh it whenever the subkey expiry is extended:
    #   gpg --export --armor 0x1B24ADB218CFB40E > home-manager/gpg/pubkey.asc
    publicKeys = [
      {
        source = ./pubkey.asc;
        trust = "ultimate";
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # Restricted socket forwarded to remotes (gpg/forward-gpg-agent.nix).
    enableExtraSocket = true;
    enableScDaemon = true;
    # drduh's cache TTLs (seconds). The card itself keeps the PIN verified
    # until it is removed; these only cover the agent-side cache.
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    defaultCacheTtlSsh = 60;
    maxCacheTtlSsh = 120;
    # GTK prompt that works under Hyprland and on GNOME. It offers "Save in
    # password manager" (gnome-keyring), which is allowed here on purpose;
    # set noAllowExternalCache = true to take that checkbox away.
    pinentry.package = pkgs.pinentry-gnome3;
    noAllowExternalCache = false;
    grabKeyboardAndMouse = true;
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };
}
