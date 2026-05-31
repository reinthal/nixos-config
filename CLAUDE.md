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
Always use the MCP-NixOS tools to confirm specific package names, module configuration options, or when creating new modules.

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
- `kog@cli-aarch64` - CLI-only config for non-NixOS systems (aarch64-linux)
- `ubuntu@lambda` - Lambda GPU servers with CUDA symlinks (x86_64-linux)

Run with: `nix run nixpkgs#home-manager -- switch --flake .#kog@cli-aarch64 --impure`
(Replace `kog@cli-aarch64` with `kog@cli` for x86_64 systems)

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

#### Security Boundary: NixOS vs Home Manager

**CRITICAL SECURITY RULE**: Maintain strict separation between system (root) and user configurations.

- **NixOS configuration** (`nixos/`): System-level, root-owned, immutable
  - Scripts run as root MUST be defined in `pkgs/` or `nixos/`
  - Secrets for root processes go in `nixos/features/sops.nix`
  - Never use home-manager configurations for root processes

- **Home Manager** (`home-manager/`): User-level, user-writable
  - Scripts and configs here can be modified by the user
  - Using these for root processes creates privilege escalation risk
  - Secrets here are for user processes only

**Examples:**
- ✅ System script in `pkgs/cache-upload.nix` → `environment.systemPackages`
- ✅ Root secrets in `nixos/features/sops.nix` → `/etc/` or `/root/`
- ❌ Root using scripts from `home-manager/scripts/` (privilege escalation)
- ❌ Root using secrets from `home-manager/sops.nix` (security boundary violation)
- ❌ Scripts with fallback to user paths (e.g., checking `~/.config` then `/etc`)

**Why this matters:**
- If root scripts trust user-writable files, users can inject malicious code/keys
- Example: signing key in `~/.config` allows user to sign malicious packages as trusted
- Always enforce single source of truth for root operations

### Pinned Inputs

Some flake inputs are deliberately held back from `nix flake update` because
the latest upstream rev breaks the build. The authoritative list lives in
README.md under "Pinned Items".

**Before running `nix flake update` or proposing input bumps:**
- Check README.md "Pinned Items" for inputs that must stay pinned.
- If `nix flake update` would advance a pinned input, restore it with:
  `nix flake lock --override-input <name> github:<owner>/<repo>/<rev>`
- When a pinned input is restored upstream (PR merged, build green), remove
  the entry from README.md and let the next `nix flake update` advance it.
- When adding a new pin, record it in README.md with: rev, reason, and the
  upstream issue/PR URL so the pin can be lifted later.

### Binary Caches

- Private: `https://tree-ams5-0003.secure.backblaze.com/reinthal-nix-store`
- Official: `https://cache.nixos.org`
- Community: `https://nix-community.cachix.org`

### Package Channels

The primary `nixpkgs` input tracks `nixpkgs-unstable`. Two additional channels
are available via overlays:

- `pkgs.unstable` - explicit nixos-unstable snapshot (`nixpkgs-unstable` input)
- `pkgs.master` - bleeding-edge master branch (`nixpkgs-master` input)

There is no stable channel. Use `pkgs.unstable.<package>` or
`pkgs.master.<package>` when a specific channel is needed.

### Overlays

To add a new package override overlay in `overlays/default.nix`:

```nix
modifications = final: prev: {
  example = prev.example.overrideAttrs (oldAttrs: {
    # patches, version changes, compilation flags, etc.
  });
};
```

Then add `outputs.overlays.modifications` to the `nixpkgs.overlays` list in
each home-manager/host config that needs it, and to the `overlays` list in
each standalone `homeConfigurations` entry in `flake.nix`.
