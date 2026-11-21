{
  pkgs,
  config,
  ...
}: let
  cfg = config.services.jellyfin;
in {
  services.meilisearch = {
    enable = true;
    package = pkgs.unstable.meilisearch;
  };
  # Runs as kog: NAS media is 1000:1000 (kog:reinthal) with mode 770/700, so
  # the `jellyfin` system user can't read it (12.4's MigrateLinkedChildren
  # migration crashed on /mnt/media/media/music).
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "kog";
  };

  # A brief switch to the `jellyfin` user re-owned the state to uid 994. `Z`
  # re-owns the contents back to cfg.user recursively (modes untouched); the
  # module's `d` rules only fix the top-level dirs. Can be dropped once flix
  # has switched.
  systemd.tmpfiles.settings.jellyfinOwnership = {
    "${cfg.dataDir}"."Z" = {
      inherit (cfg) user group;
    };
    "${cfg.cacheDir}"."Z" = {
      inherit (cfg) user group;
    };
  };

  # Configure CUDA environment for Jellyfin's ffmpeg hardware acceleration
  systemd.services.jellyfin = {
    environment = {
      # CUDA paths for development tools
      CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
      CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
      # Library path - /run/opengl-driver/lib contains NVIDIA runtime libraries (libcuda.so, libnvcuvid.so, libnvidia-encode.so)
      # cudatoolkit provides additional CUDA libraries
      LD_LIBRARY_PATH = "/run/opengl-driver/lib:${pkgs.cudaPackages.cudatoolkit}/lib";
      # Make all GPUs visible to Jellyfin
      NVIDIA_VISIBLE_DEVICES = "all";
      # Enable compute (CUDA), utility (nvidia-smi), and video (NVENC/NVDEC) capabilities
      NVIDIA_DRIVER_CAPABILITIES = "compute,utility,video";
    };
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
