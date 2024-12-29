{
  pkgs,
  lib,
  config,
  ...
}: let
  s3fs = {
    mount,
    bucket,
    keyfile,
  }: {
    systemd.services."s3fs-${bucket}" = {
      description = "Hetzner object storage S3FS";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -m 0500 -pv ${mount}"
          "${pkgs.e2fsprogs}/bin/chattr +i ${mount}" # Stop files being accidentally written to unmounted directory
        ];
        ExecStart = let
          options = [
            "passwd_file=${keyfile}"
            "allow_other"
            "uid=1000"
            "gid=100"
            "url=https://nbg1.your-objectstorage.com" # Linode object storage
            "umask=0077"
          ];
        in
          "${pkgs.s3fs}/bin/s3fs ${bucket} ${mount} -f "
          + lib.concatMapStringsSep " " (opt: "-o ${opt}") options;
        ExecStopPost = "-${pkgs.fuse}/bin/fusermount -u ${mount}";
        KillMode = "process";
        Restart = "on-failure";
      };
    };
  };
in
  s3fs {
    mount = "/mnt/media";
    bucket = "music";
    keyfile = "${config.sops.secrets."hetzner/music".path}";
  }
