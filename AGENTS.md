# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` and `flake.lock` define inputs and outputs for this multi-host NixOS/nix-darwin setup.
- `nixos/` holds system-level configs, with `nixos/hosts/` for per-host definitions and `nixos/features/` for reusable feature modules.
- `home-manager/` contains user-level configuration split by area (e.g., `cli/`, `gui/`, `hyprland/`, `plasma/`).
- `modules/` stores shared NixOS and Home Manager modules; `overlays/` contains package overlays.
- `pkgs/` is for custom packages and fonts; `secrets/` contains SOPS-encrypted secrets (e.g., `secrets/shhh.yaml`).

## Build, Test, and Development Commands
- Apply system config (NixOS): `sudo nixos-rebuild switch --flake '.#<host>' --impure`.
- Apply system config (Darwin): `nix run --experimental-features "nix-command flakes" nix-darwin -- switch --flake .#<host>`.
- Apply home-manager standalone: `nix run home-manager/master -- switch --flake .#"kog@cli" --impure`.
- Test without switching: `sudo nixos-rebuild test --flake '.#<host>' --impure`.
- Build without applying: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- Update inputs: `nix flake update` or `nix flake update nixpkgs-unstable`.
- Clean generations: `sudo bash trim-generations.sh <n items> <n days> [user|home-manager|channels|system]`.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and attribute names in `kebab-case` where appropriate (follow existing patterns).
- Module files are grouped by domain (e.g., `nixos/features/apps/*.nix`, `home-manager/gui/*.nix`).
- Prefer adding packages under `pkgs.unstable.<name>` or `pkgs.master.<name>` only when needed.

## Testing Guidelines
- There is no dedicated test framework; validation is done via `nixos-rebuild test` or `nix build`.
- When adding a host or feature, verify with the closest target host (e.g., `.#workstation` or `.#flix`).

## Commit & Pull Request Guidelines
- Commit messages follow a Conventional Commits-style pattern, e.g., `feat: add reaper`, `fix(nixbook): add default arg`, `docs(hm): ...`.
- Keep commits scoped and descriptive; include a short rationale in the PR description and link related issues if applicable.

## Security & Configuration Tips
- Secrets are managed with SOPS; reference them via `config.sops.secrets.<name>.path`.
- Avoid committing plaintext secrets or host-specific credentials.
- **IMPORTANT**: Never decrypt secrets files with `sops -d`. To check what secret keys exist, use `cat secrets/shhh.yaml` - keys are visible but values are encrypted.

## Agent-Specific Instructions
- For NixOS/Home Manager/nix-darwin lookups, prefer the MCP NixOS tools (`mcp__nixos__nix`, `mcp__nixos__nix_versions`) over web search.
