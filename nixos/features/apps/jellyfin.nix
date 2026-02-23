{
  pkgs,
  config,
  ...
}: {
  services.meilisearch = {
    enable = true;
    package = pkgs.unstable.meilisearch;
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "kog";
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
