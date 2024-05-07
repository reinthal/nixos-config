{ config, lib, pkgs, ... }:

let
 #add unstable channel declaratively
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in

{
 disabledModules = [ "services/misc/ollama.nix" ];
 imports =
  [ 
    (unstableTarball + "/nixos/modules/services/misc/ollama.nix")
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };
   # Ollama
  services.ollama = {
    package = pkgs.unstable.ollama; 
    enable = true;
    acceleration = "cuda"; 
    environmentVariables = { # I haven't been able to get this to work myself yet, but I'm sharing it for the sake of completeness
    #  # HOME = "/home/ollama";
    #  # OLLAMA_MODELS = "/home/ollama/models";
    #  OLLAMA_HOST = "0.0.0.0:11434"; # Make Ollama accesible outside of localhost
    #  # OLLAMA_ORIGINS = "http://localhost:8080,http://192.168.0.10:*"; # Allow access, otherwise Ollama returns 403 forbidden due to CORS
    };

  };


}

