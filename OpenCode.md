# OpenCode.md - NixOS Configuration Guidelines

## Build Commands
- `nixswitch` - Apply configurations to current system
- `nixup` - Update system packages and configurations
- `nixos-rebuild test --flake .#<host>` - Test without switching
- `nixos-rebuild switch --flake .#<host>` - Build specific host config
- `darwin-rebuild switch --flake .#mbp` - Build macOS config
- `./trim-generations.sh [--user|--home-manager|--channels|--system]` - Clean generations

## Code Style Guidelines
- **Imports**: Group imports at top of file, sorted alphabetically
- **Formatting**: Use 2-space indentation, trailing commas in multi-line lists
- **Naming**: Use camelCase for variables, descriptive names for modules
- **Module Structure**: 
  - System configs in `nixos/` (hosts/, features/)
  - User configs in `home-manager/` (organized by function)
  - Custom packages in `pkgs/`
  - Overlays in `overlays/`
- **Secret Management**: Use SOPS with `config.sops.secrets.<name>.path`
- **Host Configuration**: Extend from common.nix or minimal.nix base
- **Package Sources**: Prefer stable channel, use unstable/master explicitly when needed