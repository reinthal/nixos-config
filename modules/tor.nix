{ config, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."www.hottacorelay.org" = {
    root = "/var/www/hottacorelay.org";
  };

  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "exit";
  };
  settings = {
    ContactInfo = "hot.taco.relay@protonmail.com";
    Nickname = "HotTacoAdmin";
    ControlPort = 9051;
    ORPort = 443;
    BandWidthRate = "25 MBytes";
    ExitPolicy = [
    "accept *:20-21     # FTP" 
"accept *:22        # SSH" 
"accept *:23        # Telnet" 
"accept *:43        # WHOIS" 
"accept *:53        # DNS" 
"accept *:79        # finger" 
"accept *:80-81     # HTTP" 
"accept *:88        # kerberos" 
"accept *:110       # POP3" 
"accept *:143       # IMAP" 
"accept *:194       # IRC" 
"accept *:220       # IMAP3" 
"accept *:389       # LDAP" 
"accept *:443       # HTTPS" 
"accept *:464       # kpasswd" 
"accept *:465       # URD for SSM (more often: an alternative SUBMISSION port, see 587)"
"accept *:531       # IRC/AIM" 
"accept *:543-544   # Kerberos" 
"accept *:554       # RTSP" 
"accept *:563       # NNTP over SSL" 
"accept *:587       # SUBMISSION (authenticated clients [ MUA's like Thunderbird] send mail over STARTTLS SMTP here)"
"accept *:636       # LDAP over SSL" 
"accept *:706       # SILC" 
"accept *:749       # kerberos " 
"accept *:853       # DNS over TLS" 
"accept *:873       # rsync" 
"accept *:902-904   # VMware" 
"accept *:981       # Remote HTTPS management for firewall" 
"accept *:989-990   # FTP over SSL" 
"accept *:991       # Netnews Administration System" 
"accept *:992       # TELNETS" 
"accept *:993       # IMAP over SSL" 
"accept *:994       # IRCS" 
"accept *:995       # POP3 over SSL" 
"accept *:1194      # OpenVPN" 
"accept *:1220      # QT Server Admin" 
"accept *:1293      # PKT-KRB-IPSec" 
"accept *:1500      # VLSI License Manager" 
"accept *:1533      # Sametime" 
"accept *:1677      # GroupWise" 
"accept *:1723      # PPTP" 
"accept *:1755      # RTSP" 
"accept *:1863      # MSNP" 
"accept *:2082      # Infowave Mobility Server" 
"accept *:2083      # Secure Radius Service (radsec)" 
"accept *:2086-2087 # GNUnet, ELI" 
"accept *:2095-2096 # NBX" 
"accept *:2102-2104 # Zephyr" 
"accept *:3128      # SQUID" 
"accept *:3389      # MS WBT" 
"accept *:3690      # SVN" 
"accept *:4321      # RWHOIS" 
"accept *:4643      # Virtuozzo" 
"accept *:5050      # MMCC" 
"accept *:5190      # ICQ" 
"accept *:5222-5223 # XMPP, XMPP over SSL" 
"accept *:5228      # Android Market" 
"accept *:5900      # VNC" 
"accept *:6660-6669 # IRC" 
"accept *:6679      # IRC SSL  " 
"accept *:6697      # IRC SSL  " 
"accept *:8000      # iRDMI" 
"accept *:8008      # HTTP alternate" 
"accept *:8074      # Gadu-Gadu" 
"accept *:8080      # HTTP Proxies" 
"accept *:8082      # HTTPS Electrum Bitcoin port" 
"accept *:8087-8088 # Simplify Media SPP Protocol, Radan "
"accept *:8232-8233 # Zcash" 
"accept *:8332-8333 # Bitcoin" 
"accept *:8443      # PCsync HTTPS" 
"accept *:8888      # HTTP Proxies, NewsEDGE" 
"accept *:9418      # git" 
"accept *:9999      # distinct" 
"accept *:10000     # Network Data Management Protocol" 
"accept *:11371     # OpenPGP hkp (http keyserver protocol)" 
"accept *:19294     # Google Voice TCP" 
"accept *:19638     # Ensim control panel" 
"accept *:50002     # Electrum Bitcoin SSL" 
"accept *:64738     # Mumble" 
"reject *:*" 
    ];
  };
};
}
