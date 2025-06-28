{
  config,
  pkgs,
  ...
}: {
  config.systemd.tmpfiles.rules = [
    "d /var/lib/planka 770 kog users -"
    "d /var/lib/planka/favicons 770 kog users -"
    "d /var/lib/planka/user-avatars 770 kog users -"
    "d /var/lib/planka/background-images 770 kog users -"
    "d /var/lib/planka/attachments 770 kog users -"
  ];

  config.virtualisation.oci-containers.containers = {
    planka = {
      image = "ghcr.io/plankanban/planka:2.0.0-rc.3";

      extraOptions = [
        "--hostname"
        "flix"
      ];

      ports = [
        "3000:1337"
      ];

      environment = {
        BASE_URL = "https://planka.reinthal.me";
        DATABASE_URL = "postgresql://postgres:$${DATABASE_PASSWORD}@postgres/planka";
        DATABASE_PASSWORD__FILE = "/run/secrets/database_password";
        SECRET_KEY__FILE = "/run/secrets/secret_key";
        TRUST_PROXY = "true";
        DEFAULT_LANGUAGE = "en-US";
      };

      volumes = [
        "/var/lib/planka/favicons:/app/public/favicons"
        "/var/lib/planka/user-avatars:/app/public/user-avatars"
        "/var/lib/planka/background-images:/app/public/background-images"
        "/var/lib/planka/attachments:/app/private/attachments"
        "${config.sops.secrets."planka/database_password".path}:/run/secrets/database_password:ro"
        "${config.sops.secrets."planka/secret_key".path}:/run/secrets/secret_key:ro"
      ];
    };
  };

  sops = {
    secrets = {
      "planka/secret_key" = {
        owner = config.users.users.kog.name;
      };
      "planka/database_password" = {
        owner = config.users.users.kog.name;
      };
    };
  };
}
