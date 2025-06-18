{...}: {
  # Ollama Frontend
  system.activationScripts = {
    script.text = ''
      install -d -m 755 /mnt/data/kog/open-webui/data -o root -g root
      install -d -m 775 /mnt/data/kog/ollama/models/ -o root -g render
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
    host = "0.0.0.0";
    port = 11434;
    models = "/mnt/data/kog/ollama/models";
  };
}
