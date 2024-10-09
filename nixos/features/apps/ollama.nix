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
    loadModels = ["llama3.2:3b" "codellama:34b"];
  };
}
