{
  pkgs,
  lib,
  ...
}: {
  virtualisation.docker = {
    # Consider disabling the system wide Docker daemon
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
      # Optionally customize rootless Docker daemon settings
      daemon.settings = {
        dns = ["1.1.1.1" "8.8.8.8"];
        default-address-pools = [
          {
            base = "10.0.0.0/8";
            size = 27;
          }
          {
            base = "172.16.0.0/12";
            size = 27;
          }
          {
            base = "192.168.0.0/16";
            size = 27;
          }
        ];
        registry-mirrors = ["https://mirror.gcr.io"];
      };
    };
  };
  environment.systemPackages = [
    pkgs.nvidia-container-toolkit
  ];
}
