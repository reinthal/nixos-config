{ config, pkgs, ... }:
{
   config.systemd.tmpfiles.rules = ["d /home/kog/.qbittorrent 770 kog users -"];
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
         "/home/kog/.qbittorrent:/config"
         "/mnt/media/torrent:/data/torrent"
       ];
     };
   };
 }

