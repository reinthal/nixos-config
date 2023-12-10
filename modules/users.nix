{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    # Set this explicitly to where e.g. zprezto expects it
    histFile = "$HOME/.config/zsh/.zhistory";
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true; 

  users.users.kog = {
    description = "kog";
    isNormalUser = true;
    hashedPassword = "$6$WMQGBij0sndI.ZxH$eBSuf/DxQvBnPqGb0qlxXQsUPFkFWc3QKufpTSpfvKMXYcI/NkIZ51vE9vE36388Yj7QnmjACHu3Kbms6dFNm.";
    extraGroups = [ 
		 "networkmanager" 
		 "wheel"
		 "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
		git
		zsh
                fzf
		nmap
		lf    
    ];
    uid = 1000;
    openssh.authorizedKeys.keyFiles = [ 
        ../keys/battlestation.pub
        ../keys/mbpro.pub 
    ];
  };
}

