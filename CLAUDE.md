# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## MCP Server

Always use the MCP-NixOS server tools for package and configuration lookups.
The server is named `nixos` and exposes two tools:

- `mcp__nixos__nix` - Main query tool with `action` (search|info|options) and
  `source` (nixos|home-manager|darwin|flakes|wiki|nix-dev|noogle) parameters
- `mcp__nixos__nix_versions` - Get package version history from NixHub

Common usage patterns:
- **Package search**: `action: search, source: nixos`
- **Home Manager options**: `action: options, source: home-manager`
- **Darwin/macOS options**: `action: options, source: darwin`
- **Flake packages**: `action: search, source: flakes`
- **Version pinning**: use `mcp__nixos__nix_versions`

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
- `darwin/` - macOS/nix-darwin system configuration
- `modules/` - Reusable nixos/ and home-manager/ modules
- `pkgs/` - Custom packages (accessed as `pkgs.local-pkgs.<name>`)
- `overlays/` - Package modifications and channel overlays
- `secrets/` - SOPS-encrypted secrets

### Host Types

**NixOS hosts** (defined in `nixos/hosts/`):

- `workstation` - Desktop system
- `seed` - Specialized system with S3FS music bucket mounting
- `build` - x86 Proxmox VM for builds (NVIDIA, Steam, dev tools)
- `relay` - Tor exit node with high-load server tuning
- `flix` - Media server (Jellyfin, Navidrome, Pinchflat)
- `nixbook` - Apple Silicon laptop (Asahi Linux via apple-silicon input)

**Darwin host**:

- `mbp` - macOS system (nix-darwin, aarch64-darwin)

**Standalone Home Manager**:

- `kog@cli` - CLI-only config for non-NixOS systems (x86_64-linux)

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
- **IMPORTANT**: Never decrypt secrets files with `sops -d`. To check what secret keys exist, use `cat secrets/shhh.yaml` - keys are visible but values are encrypted

### Binary Caches

- Private: `https://minio.nas.reinthal.me/nix-cache`
- Official: `https://cache.nixos.org`
- Community: `https://nix-community.cachix.org`

### Package Channels

The primary `nixpkgs` input tracks `nixpkgs-unstable`. Two additional channels
are available via overlays:

- `pkgs.unstable` - explicit nixos-unstable snapshot (`nixpkgs-unstable` input)
- `pkgs.master` - bleeding-edge master branch (`nixpkgs-master` input)

There is no stable channel. Use `pkgs.unstable.<package>` or
`pkgs.master.<package>` when a specific channel is needed.
