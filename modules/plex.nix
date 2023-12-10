{ config, pkgs, ... }:
 {
   services.plex = {
       enable = true;
       openFirewall = true;
       dataDir = "/mnt/media/media/";
       extraPlugins = [
    (builtins.path {
       name = "Audnexus.bundle";
       path = pkgs.fetchFromGitHub {
       owner = "djdembeck";
       repo = "Audnexus.bundle";
       rev = "v0.2.8";
        sha256 = "sha256-IWOSz3vYL7zhdHan468xNc6C/eQ2C2BukQlaJNLXh7E=";
      };
    })
   ] 
   };
   services.tautulli = {
       enable = true;
   };
 }

