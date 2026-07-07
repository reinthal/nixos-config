# Scripts

Scripts and custom commands in this repo, grouped by where they live and how
they reach your `PATH`.

- **Bootstrap / maintenance** — plain shell scripts, run directly from the repo.
- **Custom packages** (`pkgs/`) — built as `pkgs.local-pkgs.<name>`; on `PATH`
  only if added to a `home.packages` / `environment.systemPackages`.
- **Home Manager commands** (`home-manager/scripts/`) — packaged with
  `writeShellScriptBin` and added to `home.packages`, so they are always on the
  user's `PATH` after a `switch`.

---

## Bootstrap / maintenance

### `scripts/bootstrap-home-manager.sh`

Bootstraps a non-NixOS Linux host (Ubuntu/Debian, containers included) with Nix
+ Home Manager and this repo's CLI config.

- Single-user (`--no-daemon`) Nix — works without systemd (Docker/Kubernetes).
- Runs as root or as an unprivileged user with `sudo`.
- Picks the flake config by: `FLAKE_CONFIG` env override → known hostname
  (`gpaulo-ord-0`) → arch + GPU-host heuristic (`kog@cli`, `kog@cli-aarch64`,
  `ubuntu@lambda`).
- On GPU hosts, symlinks NVIDIA/CUDA driver libs into `/run/opengl-driver/lib`.
- Enables sshd `StreamLocalBindUnlink` so a client can forward its gpg-agent
  socket in (see `setup-gpg-forward`).

```bash
# on the target host
./scripts/bootstrap-home-manager.sh
# force a specific config
FLAKE_CONFIG="alexander@gpaulo-ord-0" ./scripts/bootstrap-home-manager.sh
```

### `trim-generations.sh`

Cleans up old generations to reclaim disk.

```bash
./trim-generations.sh [--user] [--home-manager] [--channels] [--system]
```

---

## Custom packages (`pkgs/`)

Access as `pkgs.local-pkgs.<name>`. Build ad-hoc with
`nix build .#nixosConfigurations.<host>.pkgs.local-pkgs.<name>`.

### `setup-gpg-forward`

One-shot setup for **gpg-agent forwarding over SSH**. Run from the machine
holding the Yubikey (e.g. nixbook); makes a remote host sign/decrypt with this
machine's key over a forwarded agent socket.

Does: launch the local agent + confirm its restricted `.extra` socket → enable
remote sshd `StreamLocalBindUnlink` (needs passwordless sudo on the remote) →
import the public key on the remote and mark it ultimately trusted → verify by
signing a test message through the forward. The `RemoteForward` line itself is
declarative in `home-manager/gpg/forward-gpg-agent.nix`.

```bash
setup-gpg-forward <user@host> [gpg-key-id-or-email]
# KEY defaults to git user.signingkey, then $GPG_KEY
setup-gpg-forward alexander@216.153.53.92
```

### `timer-bar`

Waybar countdown module + daemon. Simple countdown or looping pomodoro, picked
from a fuzzel menu. Work/rest lengths set in `pkgs/default.nix`, overridable via
`TIMER_WORK_MIN` / `TIMER_REST_MIN`.

```bash
timer-bar [menu|status|stop]
```

### Other `pkgs/` entries

- `custom-fonts` — packaged local fonts.
- `hyprland-keybindings-menu` — fuzzel cheat-sheet of Hyprland keybindings.
- `wrapWine` / `kindle_1_17` — Wine wrapper helper and a wrapped Kindle app.

---

## Home Manager commands (`home-manager/scripts/`)

On the user's `PATH` after `switch`.

| Command | What it does |
|---|---|
| `switch` | `sudo nixos-rebuild switch --flake ~/nixos-config#$HOSTNAME --impure` (clears a stale Firefox search backup first). |
| `cache-upload [paths...]` | Sign store paths with the SOPS-deployed key and push to the B2 binary cache. No args → current system closure. |
| `secret <file>` | GPG-encrypt `<file>` to `$KEYID` → `<file>.<timestamp>.enc` (armored). |
| `reveal <file>.enc` | GPG-decrypt back to the original filename. |
| `yswitch` | Provision a duplicate Yubikey with the GPG keys (`switch-keys`). |
| `awww-wallpaper` | Set a random wallpaper from `~/Pictures/Wallpapers` via `awww`. |
| `toggle-scratchpad` | Toggle the Hyprland scratchpad (kitty dropdown via `hdrop`). |
| `start` | Hyprland startup: cursor theme + keyboard layout. |
| `gamemode` | Toggle Hyprland eye-candy (animations/blur/gaps/rounding) off/on for performance. |
| `khal-notify` | Desktop-notify calendar events in the next 15 min (`khal`), deduped via a state file. Run from a timer. |
