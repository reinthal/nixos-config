{
  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    settings = {
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      # Default preferences for new keys
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      # SHA512 as digest to sign keys
      cert-digest-algo = "SHA512";
      # SHA512 as digest for symmetric ops
      s2k-digest-algo = "SHA512";
      # AES256 as cipher for symmetric ops
      s2k-cipher-algo = "AES256";
      # UTF-8 support for compatibility
      charset = "utf-8";
      # No comments in messages
      no-comments = true;
      # No version in output
      no-emit-version = true;
      # Disable banner
      no-greeting = true;
      # Long key id format
      keyid-format = "0xlong";
      # Display UID validity
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      # Display all keys and their fingerprints
      with-fingerprint = true;
      # Display key origins and updates
      #with-key-origin
      # Cross-certify subkeys are present and valid
      require-cross-certification = true;
      # Disable caching of passphrase for symmetrical ops
      no-symkey-cache = true;
      # Output ASCII instead of binary
      armor = true;
      # Enable smartcard
      use-agent = true;
      # Disable recipient key ID in messages (breaks Mailvelope)
      throw-keyids = true;
    };
    scdaemonSettings = {
      disable-ccid = true;
    };
  };
}

