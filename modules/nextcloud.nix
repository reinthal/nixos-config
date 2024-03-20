
{ config, pkgs, ... }:
{
  services = {
    
    nextcloud = {
      enable = true;
      hostName = "dcp.sverigeskortfilmfestival.se";
      https = true;

      # increment this one version number at a time when needed
      package = pkgs.nextcloud28;
      appstoreEnable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) notify_push;
      };

      maxUploadSize = "5G";
      
      # yes please sort out a postgres db plz
      database.createLocally = true;
      # autoUpdateApps.enable = true;
      datadir = "/films/ncdata";
      skeletonDirectory = "/films/skeleton";

      # filled in to allow php to use 4GB ram using https://spot13.com/pmcalculator/
      # and was greeted with the below settings (except max_requests which is part of default nix one)
      poolSettings = {
          pm = "dynamic";
          "pm.max_children" = "112";
          "pm.max_requests" = "500";
          "pm.max_spare_servers" = "86";
          "pm.min_spare_servers" = "28";
          "pm.start_servers" = "28";
      };

      config = {
        dbtype = "pgsql";
        extraTrustedDomains = [
          "dcp.reinthal.me"
          "dcp"
          "10.22.22.79"
          "localhost"
          "127.0.0.1"
        ];
        adminpassFile = "/films/.nextcloud";
        defaultPhoneRegion = "SE";
        trustedProxies = [
          "docker.reinthal.me"
          "10.22.10.18"
        ];
        overwriteProtocol = "https";
      };

      # notify push needs redis I think so added the settings for that below. 
      # with lots of sync clients it is wise to have this option on 
      notify_push.enable = true;
      # configureRedis = true; #default is what notify_push.enable above is set to
      # caching.redis = true;
      extraOptions = {
        templateDirectory = "";
        redis = {      # with configureRedis set this is not needed
          host = "/run/redis-nextcloud/redis.sock";
          port = 0;
          dbindex = 0;
          # password = "hello to all the secret words";
          timeout = 1.5;
        };
      };
    };

    # redis = {
    #   servers.nextcloud = {
    #     enable = true;
    #     user = "nextcloud";
    #     # requirePassFile = "/films/.redis";
    #     unixSocket = "/run/redis-nextcloud/redis.sock"; #default if not specified is this path
    #     port = 0; # with 0 it only listens to local socket so need for pass
    #   };
    # };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 7867 ];
}
 
