{
  pkgs,
  lib,
  bucket,
  keyfile,
  mount,
  ...
}: {
  # Define the systemd service for mounting the S3 bucket
  systemd.services."s3fs-${bucket}" = {
    description = "S3FS Service for bucket ${bucket}";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -m 0500 -pv ${mount}"
        "${pkgs.e2fsprogs}/bin/chattr +i ${mount}" # Prevent accidental writes to unmounted directory
      ];
      ExecStart = let
        options = [
          "passwd_file=${keyfile}"
          "allow_other"
          "uid=1000"
          "gid=100"
          "url=https://nbg1.your-objectstorage.com"
          "umask=002"
        ];
      in
        "${pkgs.s3fs}/bin/s3fs ${bucket} ${mount} -f "
        + lib.concatMapStringsSep " " (opt: "-o ${opt}") options;
      ExecStopPost = "-${pkgs.fuse}/bin/fusermount -u ${mount}";
      KillMode = "process";
      Restart = "on-failure";
    };
  };

  # Ensure the mount directory is cleaned up once the service stops
  systemd.tmpfiles.rules = [
    "d ${mount} 0500 root root -"
  ];
}
