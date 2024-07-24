# Nix Configs

## todos
- [x] add teams
- [x] add languages
- [] Fix hotkeys for sound
- [] add wayland cursor
- [x] explore 1 plugin
# Uses

- flakes 
- nixos-darwin https://github.com/LnL7/nix-darwin
- home-manager https://github.com/nix-community/home-manager

# Prerequisites

From https://nixos.org/download/

```bash
sh <(curl -L https://nixos.org/nix/install)

```

and the default editor `vim` which comes with mac os.

# First time using the flake


```bash
nix run --experimental-features "nix-command flakes" nix-darwin -- switch --flake .#darwinConfigurations.Alexanders-MBP
```


After that, then experimental features for flakes will be turned on. Aliases will be set, simply run

```bash
nixswitch
```

To apply new configurations or 

```bash
nixup
```

to update and switch to new configurations.

# commit signing

Git commit signing enabled by default in home-manager
