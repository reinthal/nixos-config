{ config, pkgs, ... }:

{
  imports = [<home-manager/nixos>]; 
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true; 
  home-manager.users.kog = { pkgs, ... }: {
      imports = [ ./home/vim.nix ./home/zsh.nix ];
      home.stateVersion = "23.05";  
      home.packages = with pkgs; [
		git
		zsh
		fzf
		nmap
		lf    
		exa
		fd
		file
		fzf
		htop
		gotop
		iftop
		iotop
		ldns
		ltrace
		loc
		thefuck
		tree
		unzip
		xclip
		zip
        ];
      };
    home-manager.users.eyduh = { pkgs, ... }: {
      imports = [ ./home/vim.nix ./home/zsh.nix ];
      home.stateVersion = "23.05";  
      home.packages = with pkgs; [
                tealdeer
                helix
                distrobox
                btop

		git
		zsh
		fzf
		nmap
		lf    
		exa
		fd
		file
		fzf
		htop
		gotop
		iftop
		iotop
		ldns
		ltrace
		loc
		thefuck
		tree
		unzip
		xclip
		zip
        ];
  };

  programs.zsh.enable = true;
  users.users.eyduh = {
    description = "eyduh";
    isNormalUser = true;
    hashedPassword = "$y$j9T$bSlUyvcO4E/r3.6/MTLiq0$.w3VnUYDWi119H0WVjDp46nc01LDsUFHlR4fRg8c8s8";
    extraGroups = [ 
		 "networkmanager" 
		 "wheel"
		 "docker"
    ];
    shell = pkgs.zsh;
    uid = 1337;
    openssh.authorizedKeys.keyFiles = [ 
        ../keys/fireside.pub
        ../keys/asperitas.pub 
    ];
  };

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
    uid = 1000;
    openssh.authorizedKeys.keyFiles = [ 
        ../keys/battlestation.pub
        ../keys/mbpro.pub 
    ];
  };
}

