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
            ${pkgs.curl}/bin/curl "https://njal.la/update/?h=hottacorelay.org&k=yl2im8mkyj7iccqw&auto"
	  '';
	  serviceConfig = {
	    Type = "oneshot";
	    User = "kog";
	  };
	};
}
