{ config, pkgs, ... }:

{
  imports = [<home-manager/nixos>]; 
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true; 
  home-manager.users.kog = { pkgs, ... }: {
      imports = [ ./home/vim.nix ./home/zsh.nix ];
      home.stateVersion = "23.11";  
      home.packages = with pkgs; [
		git
		zsh
		fzf
		nmap
		lf    
		eza
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
    home-manager.users.ada = { pkgs, ... }: {
      imports = [ ./home/vim.nix ./home/zsh.nix ];
      home.stateVersion = "23.11";  
      home.packages = with pkgs; [
		git
		zsh
		fzf
		nmap
		lf    
		eza
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
  users.users.ada = {
    description = "ada";
    isNormalUser = true;
    hashedPassword = "$y$j9T$HWvOqEXKNAo71pncWn0oL.$SCSg00gwPa9UzNjfFQN2q3TTpIt.7LYj7R3li51Q8m8";
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
    # To use this shell.nix on NixOS your user needs to be configured as such:
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
    openssh.authorizedKeys.keyFiles = [ 
        ../keys/battlestation.pub
        ../keys/mbpro.pub
        ../keys/build.pub
    ];
  };
}

