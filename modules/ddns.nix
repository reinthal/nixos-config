{ config, pkgs, ... }:
{
	systemd.timers."ddns" = {
	  wantedBy = [ "timers.target" ];
	    timerConfig = {
	      OnCalendar="*-*-* *:00:00";
              Unit = "ddns.service";
	    };
	};

	systemd.services."ddns" = {
	  script = ''
	    ${pkgs.curl}/bin/curl "https://njal.la/update/?h=www.hottacorelay.org&k=9dp54s0lz8zisyky&auto"
	  '';
	  serviceConfig = {
	    Type = "oneshot";
	    User = "kog";
	  };
	};
}
