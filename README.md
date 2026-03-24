# NixOS Configuration

<div align="center">

![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white)
![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-blue.svg?style=for-the-badge&logo=nixos&logoColor=white)

</div>

Welcome to my NixOS configuration repository! This is a multi-host flake-based
setup supporting both NixOS and Darwin systems. These configurations represent
my reproducible, declarative system setups for my linux machines.

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

You can run the full bootstrap as a script:

```bash
./scripts/bootstrap-home-manager.sh
```

Manual steps:

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

allow flakes and trust root and current user add devenv public key

```
sudo tee -a /etc/shells <<EOF
$(which zsh)
EOF
```

```bash
sudo tee -a /etc/nix/nix.conf <<EOF
experimental-features = nix-command flakes
trusted-users = root $(whoami)
extra-substituters = https://devenv.cachix.org
extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= reinthal-cache.cachix.org-1:wFPDVH/makS72ZY3Y8jA0BehXDBhQ3syqo0UJu7oah8=
EOF
```

restart the nix daemon

```bash
sudo systemctl restart nix-daemon
```

```bash
sudo tee -a /etc/shells <<EOF
/home/$(whoami)/.nix-profile/bin/zsh
EOF
```

install home-manager cli environment

```bash
home-manager switch --flake .#kog@cli --impure -b bkp && sudo chsh -s $(which zsh) && echo  'WELCOME TO NIXLAND'  && zsh
```

### Applying changes (standalone)

After the initial bootstrap, the `home-manager` binary is no longer in `PATH`
because home-manager takes over `~/.nix-profile`. Use `nix run` instead:

```bash
nix run home-manager/master -- switch --flake .#"kog@cli" --impure
```

The `--impure` flag is required because the config reads `$USER` and `$HOME`
via `builtins.getEnv` to set `home.username` and `home.homeDirectory`, keeping
the config user-agnostic without needing separate flakes per user.

## Hosts

| Host          | Description                              |
| ------------- | ---------------------------------------- |
| `build`       | x86 Proxmox VM Workstation               |
| `flix`        | Media server (Jellyfin, Plex, Navidrome) |
| `nixbook`     | Apple Silicon + NixOS configuration      |
| `relay`       | Tor exit node                            |
| `mbp`         | macOS Darwin system                      |

## Package Channels

This flake uses two nixpkgs inputs that both track the `nixpkgs-unstable`
branch but are pinned independently in `flake.lock`. The reason the entire
setup runs on unstable is the `nixos-apple-silicon` module, which requires
kernel support only available on the unstable branch.

### Inputs

| Input | Branch | Accessed as | Purpose |
|---|---|---|---|
| `nixpkgs` | `nixpkgs-unstable` | `pkgs.*` | Default system and home-manager packages |
| `nixpkgs-unstable` | `nixpkgs-unstable` | `pkgs.unstable.*` | High-churn packages on a faster update cadence |

Both inputs track the same upstream branch. The separation exists so that
`pkgs.unstable.*` packages can be updated independently (via
`nix flake update nixpkgs-unstable`) without triggering a full system rebuild
from a new `nixpkgs` pin.

### When to use `pkgs.unstable.*`

Add a package under `pkgs.unstable.<name>` when:
- It moves fast and you want updates more frequently than system rebuilds
- You had a breakage in the main `nixpkgs` pin and need a newer snapshot
- The package lags behind in the main pin (e.g. waiting for a Hydra build)

Current `pkgs.unstable.*` packages:

| Package | File |
|---|---|
| `signal-desktop` | `home-manager/cli/default.nix` |
| `claude-code` | `home-manager/cli/default.nix`, `home-manager/cli/flix.nix` |
| `mcp-proxy` | `home-manager/cli/default.nix` |
| `devenv` | `home-manager/cli/default.nix` |
| `ollama` | `modules/ollama.nix` |
| `meilisearch` | `nixos/features/apps/jellyfin.nix` |

### Update paths

Update only the high-churn input (fast, low rebuild impact):

```bash
nix flake update nixpkgs-unstable
```

Update everything (full system rebuild on next `switch`):

```bash
nix flake update
```

Update a single other input:

```bash
nix flake update home-manager
nix flake update apple-silicon
```

## Pinned Items

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
switch
```

#### Update system packages and configurations:

```bash
nix flake update
```
or 

```bash
nix flake update nixpkgs-unstable
```

#### Test configurations without switching:

```bash
sudo nixos-rebuild test --flake '.#<host>' --impure
```

#### Clean up old generations:

```bash
sudo bash trim-generations.sh <n items> <n days> [user|home-manager|channels|system]
```

## Cache

```
nix store sign --recursive --key-file ~/.config/nix/secret.key /run/current-system
```

```
nix copy --to 's3://nix-cache?profile=nixbuilder&endpoint=minio.nas.reinthal.me' /run/current-system
```
