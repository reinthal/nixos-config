# Hyprland Keybindings

This document lists all keybindings configured in `hyprland.nix`.

## Applications

| Keybind | Action |
|---------|--------|
| `SUPER + Return` | Open terminal (ghostty) |
| `SUPER + Space` | Application launcher (fuzzel), on release |
| `SUPER + /` | Keybindings menu (searchable) |
| `SUPER + W` | Open Firefox |
| `SUPER + H` | Tasks (linear.app): jump to its workspace, start if empty |
| `SUPER + J` | LLM (claude-desktop): jump to its workspace, start if empty |
| `SUPER + M` | Slack |
| `SUPER + N` | Discord |
| `SUPER + V` | Email (Proton): jump to its workspace, start if empty |
| `SUPER + C` | Code (VSCodium): jump to its workspace, start if empty |
| `SUPER + K` | Signal |
| `SUPER + O` | Obsidian |
| `SUPER + P` | Vault (vault.reinthal.me): jump to its workspace, start if empty |
| `SUPER + L` | Toggl: jump to its workspace, start if empty |
| `SUPER + E` | Calendar (Proton): jump to its workspace, start if empty |

## Window Management

| Keybind | Action |
|---------|--------|
| `SUPER + Q` | Kill active window |
| `SUPER + F` | Toggle floating mode |
| `SUPER + G` | Toggle fullscreen |
| `SUPER + T` | Toggle split layout |
| `ALT + Tab` | Focus current or last window |
| `SUPER + Tab` | Window switcher: hold SUPER, Tab to move down the list (most recent first), release SUPER to focus; Escape cancels |
| `SUPER SHIFT + Tab` | Window switcher, moving up the list |

## Focus Navigation

| Keybind | Action |
|---------|--------|
| `SUPER ALT + k` | Move focus up |
| `SUPER ALT + j` | Move focus down |
| `SUPER ALT + l` | Move focus right |
| `SUPER ALT + h` | Move focus left |

## Workspace Management

| Keybind | Action |
|---------|--------|
| `SUPER + 1-5` | Main monitor workspace 1-5 |
| `SUPER + Space + 1-5` | Secondary monitor workspace 6-10 (hold Space) |
| `SUPER + Left` | Previous workspace |
| `SUPER + Right` | Next workspace |
| `SUPER SHIFT + 1-5` | Move window to workspace 1-5 |
| `SUPER SHIFT + Space + 1-5` | Move window to workspace 6-10 |
| `SUPER SHIFT + Left` | Move window to previous workspace |
| `SUPER SHIFT + Right` | Move window to next workspace |

## Scratchpad

| Keybind | Action |
|---------|--------|
| `SUPER + S` | Open scratchpad |
| `SUPER + r` | Scratchpad `-g -l` |
| `CTRL SHIFT + s` | Toggle scratchpad |

## Notifications

| Keybind | Action |
|---------|--------|
| `SUPER + D` | Dismiss notification |
| `SUPER SHIFT + D` | Dismiss all notifications |

## Screenshots

| Keybind | Action |
|---------|--------|
| `SUPER SHIFT + S` | Screenshot region to clipboard |

## System

| Keybind | Action |
|---------|--------|
| `SUPER + B` | Change wallpaper |
| `CTRL SUPER + Q` | Lock screen (swaylock) |
| `CTRL SUPER + G` | Toggle gamemode |
| `CTRL ALT + D` | Exit Hyprland |

## Audio

| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Increase volume 5% |
| `XF86AudioLowerVolume` | Decrease volume 5% |
| `XF86AudioPlay` / `XF86AudioPause` | Play/pause (MPRIS via wayle) |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Mouse Bindings

| Keybind | Action |
|---------|--------|
| `SUPER + Left Click` | Move window |
| `SUPER + Right Click` | Resize window |
