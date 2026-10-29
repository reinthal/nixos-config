# Fingerprint reader (fprintd), used for sudo, polkit and the lock screen.
#
# The ReGreet login takes the password only: gnome-keyring is encrypted with
# the login password and a fingerprint gives PAM nothing to unlock it with.
#
# Enroll once (as the user):  fprintd-enroll   then   fprintd-verify
{lib, ...}: {
  services.fprintd.enable = true;

  security.pam.services = {
    # Password at the greeter and on ttys -> keyring unlocks at login.
    greetd.fprintAuth = false;
    login.fprintAuth = false;
    # hyprlock talks to fprintd over D-Bus itself (auth.fingerprint in
    # hyprlock.conf); PAM's fprintd would block the password field.
    hyprlock.fprintAuth = false;
    # swaylock only calls PAM after Enter, so fprintd there is unusable.
    swaylock.fprintAuth = false;
    # Fingerprint is enough for sudo / polkit; Ctrl+C falls back to password.
    sudo.fprintAuth = lib.mkDefault true;
    polkit-1.fprintAuth = lib.mkDefault true;
  };
}
