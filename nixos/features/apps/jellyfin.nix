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
  # Runs as the module's default `jellyfin` system user (not kog), so an
  # ffmpeg exploit via a crafted library file stays inside that account.
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [
    "users" # media on the NAS is group `users` (qbittorrent writes PGID 100, UMASK 002)
    "video" # GPU device nodes for NVENC/NVDEC
    "render"
  ];

  # Jellyfin used to run as kog, so its existing state is kog-owned. The
  # module's `d` rules only fix the top-level dirs; `Z` re-owns the contents
  # recursively (modes untouched). Can be dropped once flix has switched.
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
