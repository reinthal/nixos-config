# NixOS Configuration

<div align="center">

![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white)
![NixOS](https://img.shields.io/badge/NixOS-25.05-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-blue.svg?style=for-the-badge&logo=nixos&logoColor=white)

</div>

Welcome to my NixOS configuration repository! This is a multi-host flake-based
setup supporting both NixOS and Darwin systems. These configurations represent
my reproducible, declarative system setups for various machines and use cases.

## Repository Structure

- **`nixos/`** - System-level configurations
  - `hosts/` - Machine-specific configurations
  - `features/` - Modular system features (networking, desktop environments,
    etc.)
  - `common.nix` - Extended baseline with fonts and utilities
  - `minimal.nix` - Minimal baseline for headless systems

- **`home-manager/`** - User-level configurations
  - `cli/` - Terminal and command-line tools
  - `gui/` - Graphical applications and settings
  - `hyprland/` - Hyprland window manager configuration
  - `terminal/` - Terminal emulator settings
  - `plasma/` - KDE Plasma desktop environment

- **`modules/`** - Reusable NixOS and home-manager modules
- **`pkgs/`** - Custom packages and fonts
- **`overlays/`** - Package modifications
- **`secrets/`** - SOPS-encrypted secrets

## Bootstrapping a Linux environment (Home-manager)

```bash
sudo apt update && sudo apt install -y curl git gh vim
```

installing nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

installing home manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager && nix-channel --update && nix-shell '<home-manager>' -A install
```

```bash
git clone https://github.com/reinthal/nixos-config
cd nixos-config
```

allow flakes

```
sudo tee -a /etc/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

```bash
home-manager switch --flake .#kog@cli --impure
```

## Hosts

| Host          | Description                              |
| ------------- | ---------------------------------------- |
| `workstation` | Primary desktop system                   |
| `seed`        | Specialized system configuration         |
| `build`       | x86 Proxmox VM for builds                |
| `flix`        | Media server (Jellyfin, Plex, Navidrome) |
| `nixbook`     | Apple Silicon + NixOS configuration      |
| `relay`       | Tor exit node setup                      |
| `mbp`         | macOS Darwin system                      |
| `dcp`         | DCP system configuration                 |
| `default`     | Default system configuration             |
| `flow`        | Flow system configuration                |

## Pinned Items

- [ ] Input nixpkgs from hyprland hotfix PR
      1284004bf6c6e50d8592b6efe83708931e75aec7
- [ ] `features/nvidia.nix` boot.kernelPackages = lib.mkDefault
      pkgs.linuxPackages_6_10;

## Building the System

### First Time Setup

For NixOS systems:

```bash
sudo nixos-rebuild switch --flake '.#<hostname>' --impure
```

For Darwin (macOS) systems:

```bash
nix run --experimental-features "nix-command flakes" nix-darwin -- switch --flake .#<hostname>
```

### After Initial Setup

Once experimental features for flakes are enabled, use these convenient aliases:

#### Apply new configurations:

```bash
nixswitch
```

#### Update system packages and configurations:

```bash
nixup
```

#### Build specific hosts:

```bash
sudo nixos-rebuild switch --flake '.#workstation' --impure
sudo nixos-rebuild switch --flake '.#seed' --impure
sudo nixos-rebuild switch --flake '.#relay' --impure
sudo nixos-rebuild switch --flake '.#flix' --impure
darwin-rebuild switch --flake .#mbp
```

#### Test configurations without switching:

```bash
sudo nixos-rebuild test --flake '.#<host>' --impure
```

#### Update flake inputs:

```bash
nix flake update
```

#### Clean up old generations:

```bash
./trim-generations.sh [--user|--home-manager|--channels|--system]
```

## Cache

```
nix store sign --recursive --key-file ~/.config/nix/secret.key /run/current-system
```

```
nix copy --to 's3://nix-cache?profile=nixbuilder&endpoint=minio.nas.reinthal.me' /run/current-system
```
