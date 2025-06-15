# Nix Configs

My repeatable babies  :)

## Pinned 
- [] input nixpkgs from hyprland hotfix PR 1284004bf6c6e50d8592b6efe83708931e75aec7
- [] `features/nvidia.nix` boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_10;

## Hosts

- `workstation` - Work desktop system
- `seed` - Specialized system configuration  
- `build` - Main home desktop workstation
- `dcp` - DCP system configuration
- `default` - Default system configuration
- `flix` - Media server (Jellyfin, Plex, Navidrome)
- `flow` - Flow system configuration
- `nixbook` - Apple Silicon + NixOS configuration
- `relay` - Tor exit node setup
- `mbp` - macOS Darwin system

# Building the System

## First Time Setup

For NixOS systems:
```bash
sudo nixos-rebuild switch --flake '.#<hostname>' --impure
```

For Darwin (macOS) systems:
```bash
nix run --experimental-features "nix-command flakes" nix-darwin -- switch --flake .#<hostname>
```

## Available Hosts

- `workstation` - Primary desktop system
- `seed` - Specialized system configuration  
- `build` - x86 Proxmox VM for builds
- `dcp` - DCP system configuration
- `default` - Default system configuration
- `flix` - Media server (Jellyfin, Plex, Navidrome)
- `flow` - Flow system configuration
- `nixbook` - Apple Silicon + NixOS configuration
- `relay` - Tor exit node setup
- `mbp` - macOS Darwin system

## After Initial Setup

Once experimental features for flakes are enabled, use these convenient aliases:

### Apply new configurations:
```bash
nixswitch
```

### Update system packages and configurations:
```bash
nixup
```

### Build specific hosts:
```bash
sudo nixos-rebuild switch --flake '.#workstation' --impure
sudo nixos-rebuild switch --flake '.#seed' --impure
sudo nixos-rebuild switch --flake '.#relay' --impure
sudo nixos-rebuild switch --flake '.#flix' --impure
darwin-rebuild switch --flake .#mbp
```

### Test configurations without switching:
```bash
sudo nixos-rebuild test --flake '.#<host>' --impure
```

### Update flake inputs:
```bash
nix flake update
```

