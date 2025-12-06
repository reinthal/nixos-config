# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## MCP Server

Always use the MCP-NixOS server tools for package and configuration lookups:

- **Package verification**: Use `nixos_search` and `nixos_info` to verify packages exist and get details
- **Home Manager options**: Use `home_manager_search` and `home_manager_info` instead of web searches
- **Darwin/macOS options**: Use `darwin_search` and `darwin_info` for nix-darwin configurations
- **Version pinning**: Use `nixhub_package_versions` or `nixhub_find_version` when specific package versions are needed
- **Flake packages**: Use `nixos_flakes_search` for community flakes and packages not in nixpkgs

Prefer MCP tools over WebSearch for all NixOS, Home Manager, and nix-darwin queries.

## Development Commands

### Primary Commands

- `switch` - Apply new configurations to current system
- `nix flake update` - Update all flake inputs
- `./trim-generations.sh` - Clean up old system generations (supports --user,
  --home-manager, --channels, --system flags)
- `darwin-rebuild switch --flake .#mbp` - Build macOS config

### Testing Changes

- `nixos-rebuild test --flake .#<host>` - Test configuration without switching
- `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` - Build
  system without applying

## Architecture

### Repository Structure

This is a multi-host NixOS flake configuration supporting both NixOS and Darwin
systems.

**Core Directories:**

- `nixos/` - System-level configurations with hosts/ and features/
  subdirectories
- `home-manager/` - User-level configurations including GUI, CLI, and desktop
  environments
- `modules/` - Reusable nixos/ and home-manager/ modules
- `pkgs/` - Custom packages and fonts
- `overlays/` - Package modifications
- `secrets/` - SOPS-encrypted secrets

### Host Types

- `workstation` - deprecated desktop system
- `seed` - Specialized system configuration
- `build` - x86 Proxmox VM for builds
- `relay` - Tor exit node setup
- `flix` - Media server (Jellyfin, Plex, Navidrome)
- `nixbook` - Apple Silicon + NixOS configuration
- `mbp` - macOS Darwin system

### Key Configuration Patterns

- `nixos/common.nix` - Extended baseline with fonts and utilities
- `nixos/minimal.nix` - Minimal baseline for headless systems
- `home-manager/` configs are modular by function (gui/, cli/, hyprland/, etc.)
- Features are organized in `nixos/features/` and imported selectively per host

### Desktop Environments

- Hyprland with custom icons and Pyprland integration

### Security & Secrets

- SOPS for secrets management with `secrets/shhh.yaml`
- GPG and Yubikey support configured
- Secrets referenced via `config.sops.secrets.<name>.path`

### Binary Caches

- Private: `https://minio.nas.reinthal.me/nix-cache`
- Official: `https://cache.nixos.org`
- Community: `https://nix-community.cachix.org`

### Package Channels

Uses stable (25.11), unstable, and master branches via flake inputs. Master
packages available as `inputs.master.legacyPackages.${system}.<package>`.

