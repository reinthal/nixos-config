# Nix Generation Lifecycle Management

## What Are Generations?

A **generation** is an immutable snapshot of your system or user environment at a specific point in time. It's essentially a symlink to a specific configuration in the Nix store (`/nix/store`). This allows you to roll back to previous states if something breaks.

## Two Separate Profile Types

Nix maintains separate generation histories for different profiles. These are **completely independent**:

### 1. System Profile (`/nix/var/nix/profiles/system`)

- **Created by**: `nixos-rebuild switch/boot/test`
- **Contains**: Entire system configuration (kernel, services, system packages)
- **Managed by**: root/sudo
- **Requires sudo to delete**: Yes
- **Visible in**: GRUB/systemd-boot menu at boot time

### 2. User Profile (`~/.nix-profile` or `/nix/var/nix/profiles/per-user/$USER/profile`)

- **Created by**: `nix-env -i/u/e`, `home-manager switch`
- **Contains**: User-installed packages, home-manager configurations
- **Managed by**: individual users
- **Requires sudo to delete**: No
- **Visible in**: Command-line only

## What Creates Generations?

### System Generations

```bash
sudo nixos-rebuild switch   # Creates new generation and switches to it
sudo nixos-rebuild boot     # Creates new generation for next boot
sudo nixos-rebuild test     # Creates generation but doesn't set as default
```

Every time you run any of these commands, a new system generation is created, even if nothing changed.

### User Generations

```bash
nix-env -i package          # Install a package
nix-env -e package          # Remove a package
nix-env -u                  # Upgrade packages
home-manager switch         # Apply home-manager configuration
```

## Checking Generations

### List User Profile Generations

```bash
nix-env --list-generations
```

### Count User Generations

```bash
nix-env --list-generations | wc -l
```

### List System Generations

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Count System Generations (without sudo)

```bash
ls -1 /nix/var/nix/profiles/system-*-link | wc -l
```

### Check Current Generation

```bash
readlink /nix/var/nix/profiles/system  # System
readlink ~/.nix-profile                # User
```

## Manual Cleanup

### User Profile Cleanup (No sudo needed)

```bash
# Keep only current generation
nix-env --delete-generations old

# Delete generations older than 30 days
nix-env --delete-generations 30d

# Delete specific generations
nix-env --delete-generations 1 2 3

# Keep last N generations
nix-env --delete-generations +5
```

### System Profile Cleanup (Requires sudo)

```bash
# Keep only current generation
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Delete generations older than 30 days
sudo nix-env --delete-generations 30d --profile /nix/var/nix/profiles/system

# Keep last N generations
sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system
```

### Reclaim Disk Space

**IMPORTANT**: Deleting generations only removes the symlinks. To actually free up disk space, you must run garbage collection:

```bash
# Clean user profile store paths
nix-collect-garbage

# Clean system + user store paths (recommended)
sudo nix-collect-garbage -d

# Optimize store (deduplicate hard links)
nix-store --optimize
```

## Automatic Cleanup (Recommended)

Add this to your NixOS configuration to automatically clean up old generations:

```nix
# Automatic garbage collection
nix.gc = {
  automatic = true;
  dates = "weekly";           # Run weekly
  options = "--delete-older-than 30d";  # Delete generations older than 30 days
};

# Limit bootloader entries (optional)
# This keeps only N most recent generations in the boot menu
# WARNING: This deletes generations, not just hides them
boot.loader.systemd-boot.configurationLimit = 50;

# OR for GRUB:
boot.loader.grub.configurationLimit = 50;
```

### Time-Based vs Count-Based Limits

**Time-based** (Recommended):
```nix
nix.gc.options = "--delete-older-than 30d";
```
- Keeps all recent work regardless of how many rebuilds you do
- Better for iterative development and experimentation
- Prevents accidental deletion during rapid testing cycles
- Storage usage is predictable and bounded by time

**Count-based** (Use with caution):
```nix
boot.loader.systemd-boot.configurationLimit = 10;
```
- Deletes older generations once limit is exceeded
- Can backfire during rapid development (10 rebuilds = no rollback history)
- Useful only if you want a hard upper bound on boot menu entries
- Still recommended to keep this reasonably high (30-50) to avoid data loss

**Best practice**: Use time-based cleanup for garbage collection and a high count limit (30-50) for bootloader entries.

## Rollback

### User Profile Rollback

```bash
# Rollback to previous generation
nix-env --rollback

# Switch to specific generation
nix-env --switch-generation 42
```

### System Rollback

**Method 1**: Select older generation in GRUB/systemd-boot at boot time

**Method 2**: Switch to specific generation manually

```bash
# List generations with numbers
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Switch to specific generation
sudo /nix/var/nix/profiles/system-123-link/bin/switch-to-configuration switch
```

## Generation Lifecycle Best Practices

1. **Keep at least 3-5 recent generations** in case you need to rollback
2. **Use time-based cleanup** for automatic garbage collection (e.g., 30 days)
3. **Set a high bootloader limit** (30-50) to keep rollback options available
4. **Run garbage collection regularly** to reclaim disk space
5. **Test changes** with `nixos-rebuild test` before committing to `switch`
6. **Monitor disk usage** with `du -sh /nix/store`

## Common Issues

### "No space left on device"

Run garbage collection:
```bash
sudo nix-collect-garbage -d
nix-store --optimize
```

### Boot menu is cluttered

Set a bootloader configuration limit:
```nix
boot.loader.systemd-boot.configurationLimit = 30;
```

### Can't rollback after cleanup

This is by design - you deleted the generations. Keep more generations or use time-based cleanup.

## Storage Impact

Each generation is essentially a symlink (negligible space), but the underlying store paths consume significant disk space. Garbage collection removes unreferenced store paths that no generation depends on.

Example:
- 646 system generations might reference thousands of unique store paths
- `/nix/store` can easily grow to 100GB+ without cleanup
- After cleanup: only paths referenced by kept generations remain

## Safety Notes

1. **Deleting generations is permanent** - you can't recover them
2. **System generations let you boot into previous configurations** - keep several for safety
3. **Garbage collection only removes unreferenced store paths** - it won't delete anything a generation still uses
4. **Always test before deleting** - especially on production systems
5. **User and system generations are independent** - deleting one doesn't affect the other

## Repository-Specific Scripts

This repository includes `trim-generations.sh` for manual cleanup:

```bash
# Clean up old system generations
./trim-generations.sh --system

# Clean up user profile
./trim-generations.sh --user

# Clean up home-manager
./trim-generations.sh --home-manager

# Clean up all
./trim-generations.sh --all
```

See `trim-generations.sh` for more options.

## Store Still Full After Trimming Generations?

Generation cleanup only frees paths that *no generation* references. If
`/nix/store` stays huge after trimming, the space is pinned by other GC roots —
most often per-project `devenv`/`direnv` shells and stray `result` symlinks. See
[`reclaiming-store-space.md`](./reclaiming-store-space.md) for the full
diagnostic procedure.
