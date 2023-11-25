{ config, pkgs, ... }:
 {
   config.virtualisation.oci-containers.containers = {
     qbittorrent = {
       image = "lscr.io/linuxserver/qbittorrent:latest";
       ports = ["8080:8080" "5225:5225"];
       environment = {
          PUID = "1000";
          PGID = "100";
          UMASK = "002";
          TZ="Etc/Stockholm";
       };
       volumes = [
         "/home/kog/appdata/qbittorrent:/config"
         "/mnt/media/torrent:/data/torrent"
       ];
     };
   };
 }

