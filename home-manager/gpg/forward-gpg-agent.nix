{pkgs, ...}: let
  # gpg-agent forwarding over SSH.
  #
  # Signs/decrypts on a remote host using THIS machine's Yubikey. The remote
  # holds no key material: its gpg talks to our forwarded agent socket.
  #
  # We forward the LOCAL "extra" socket (restricted: crypto ops only, refuses
  # key management) onto the remote's standard agent-socket path, so remote
  # gpg picks it up transparently.
  #
  # Local uid is kog=1000 on every host in this repo.
  localExtraSocket = "/run/user/1000/gnupg/S.gpg-agent.extra";

  # Bind the remote's standard agent-socket to our local extra socket.
  # Verify a remote uid with: gpgconf --list-dirs agent-socket
  forwardTo = remoteUid: {
    RemoteForward = [
      {
        bind.address = "/run/user/${toString remoteUid}/gnupg/S.gpg-agent";
        host.address = localExtraSocket;
      }
    ];
    # Unlink a stale remote socket before binding. Only takes effect if the
    # remote sshd has `StreamLocalBindUnlink yes` (set for build via nixos;
    # on gpaulo add it to /etc/ssh/sshd_config.d/).
    StreamLocalBindUnlink = "yes";
  };
in {
  # `setup-gpg-forward <user@host>` — provision the remote + verify the forward.
  home.packages = [pkgs.local-pkgs.setup-gpg-forward];

  programs.ssh = {
    enable = true;
    # Opt out of the deprecated implicit defaults; set them explicitly below.
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      # gpaulo-ord-0 (Docker container) — reachable only by IP, no working name.
      "216.153.53.92" = forwardTo 1001 // {User = "alexander";};
      "build.reinthal.me" =
        forwardTo 1000
        // {
          User = "kog";
          # Authenticate with the Yubikey's OpenPGP auth key via gpg-agent's
          # ssh socket, not a private key file on disk.
          IdentityFile = "~/.ssh/openpgp";
          IdentitiesOnly = true;
          PreferredAuthentications = "publickey";
          PubkeyAuthentication = true;
          IdentityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
        };
    };
  };
}
