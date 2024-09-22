# Nix Configs

My repeatable babies  :)

## Pinned 
- [] input nixpkgs from hyprland hotfix PR 1284004bf6c6e50d8592b6efe83708931e75aec7
- [] `features/nvidia.nix` boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_10;

## Hosts

- Build, x86 proxmox vm with nixos
- Macosx Darwin, vanilla Macosx
- Relay, Tor Exit Node
- nixbook, apple silicon + nixos

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

