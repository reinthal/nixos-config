{ config, pkgs, ... }:
 {
   config.virtualisation.oci-containers.containers = {
     qbittorrent = {
       image = "lscr.io/linuxserver/qbittorrent:latest";
       ports = ["8080:8080" "5225:5225"];
       volumes = [
         "/home/kog/dockers/flow/qbittorrent/appdata/:/config"
         "/mnt/media/torrent:/data/torrent"
       ];
     };
   };
 }

