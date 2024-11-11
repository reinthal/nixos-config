{
  config,
  lib,
  pkgs,
  ...
}: {
  # Ollama Frontend
  system.activationScripts = {
    script.text = ''
      install -d -m 755 /home/kog/open-webui/data -o root -g root
    '';
  };
  environment.systemPackages = [
    pkgs.nvidia-container-toolkit
  ];
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };

    oci-containers = {
      backend = "podman";

      containers = {
        open-webui = import ../containers/open-webui.nix;
      };
    };
  };
  # Ollama Server
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
  };
}
