# Reclaiming `/nix/store` Space

When `/nix/store` is much larger than your current system closure, the extra
weight is almost always **live GC roots** pinning store paths that garbage
collection is therefore not allowed to delete. Old generations are only one
kind of root; on a dev machine the bigger offenders are usually per-project
`devenv`/`direnv` shells and stray `result` symlinks.

This guide is the diagnostic companion to
[`generation-lifecycle.md`](./generation-lifecycle.md): that file covers
generations; this one covers everything *else* that keeps the store from
shrinking.

## 1. Measure the gap

```bash
# Size of the current system closure (what you actually need to boot/run)
nix path-info -Sh /run/current-system

# Actual store size on disk
du -d 1 -h /nix/store
```

If the store is tens of GiB larger than the closure, keep going — that gap is
reclaimable.

## 2. Check generations first (usually NOT the cause)

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
nix run nixpkgs#home-manager -- generations
```

If you only have one or two generations of each, generations are not your
problem — skip to step 3. If you have many, see
[`generation-lifecycle.md`](./generation-lifecycle.md).

## 3. List every GC root

This is the key command. It prints everything currently pinning the store:

```bash
nix-store --gc --print-roots | grep -v /proc | sort
```

Read the output by category:

| Root pattern | What it is | Safe to remove? |
| --- | --- | --- |
| `.../profiles/system-*-link` | System generations | Only via generation cleanup |
| `.../home-manager-*-link`, `current-home` | Home Manager generations | Only via HM cleanup |
| `.../per-user/root/channels-*-link` | Root `nix-channel` closure | Yes if the system is flake-based and you never use `nix-channel` |
| `**/.devenv/gc/*`, `**/.devenv/bash*` | Per-project `devenv` shells | Yes — rebuilds on next `devenv shell` / direnv enter |
| `**/result` | Leftover `nix build` outputs | Yes — rebuild with `nix build` when needed |
| `**/flake-registry.json` | Flake registry cache | Leave it (tiny) |

On this repo's dev machines the `.devenv/gc` roots dominate: each pins a full
dev toolchain closure (Python, Node, compilers), and a handful of active repos
easily add 20–30 GiB.

## 4. Rank the heavy roots before deleting

Only nuke the big ones. This prints closure size per devenv shell, smallest
first:

```bash
for d in $(find "$HOME" -type d -name .devenv 2>/dev/null); do
  echo "$(nix path-info -Sh "$d"/gc/shell 2>/dev/null | awk '{print $2}') $d"
done | sort -h
```

## 5. Remove the dead roots

```bash
# Stray build outputs
find "$HOME" -name result -type l -maxdepth 4 -print   # review first
# ...then rm the ones you don't need

# devenv shells for repos you are NOT actively building
rm -rf /path/to/repo/.devenv/gc
# or sweep all of them (active projects just rebuild on next entry):
find "$HOME" -type d -name .devenv -prune -exec rm -rf {}/gc \; 2>/dev/null

# Stale root channel (only if the system is flake-based and channels are unused)
sudo rm /nix/var/nix/profiles/per-user/root/channels-*-link
```

> **Note:** Removing a `.devenv/gc` root is *not* data loss — the next
> `devenv shell` / direnv `cd` rebuilds or re-fetches the environment. The only
> cost is a slower first entry.

## 6. Garbage-collect and optimize

Removing roots frees nothing on its own; you must run GC:

```bash
nix-collect-garbage -d          # user profile: drop old gens + collect
sudo nix-collect-garbage -d     # system profile: same, as root
nix store optimise              # dedup identical files via hardlinks
```

Re-check with `du -d 1 -h /nix/store` — the store should now be close to the
sum of the closures you actually kept.

## Preview before committing

Both accept `--dry-run` to show what *would* be deleted:

```bash
nix-collect-garbage --delete-older-than 7d --dry-run
sudo nix-collect-garbage -d --dry-run
```

## Quick reference

```bash
nix path-info -Sh /run/current-system          # what you need
du -d 1 -h /nix/store                           # what you have
nix-store --gc --print-roots | grep -v /proc    # why it won't shrink
find "$HOME" -type d -name .devenv -prune -exec rm -rf {}/gc \;  # drop devenv roots
sudo nix-collect-garbage -d && nix store optimise               # reclaim
```
