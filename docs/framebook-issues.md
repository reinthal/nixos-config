# Framebook — open issues

Running log of known issues on the `framebook` host and their diagnosis/status.

## 1. Wayle network GUI "failed" on click

**Symptom:** Clicking the network module in the wayle bar just reads "failed";
`nmcli` reportedly works.

**Diagnosis:** There are **two independent problems**. Neither is a wayle GUI
bug in the usual sense — #1 is a D-Bus lifecycle bug, #2 is the wifi layer.

### 1a. D-Bus startup race — module disappears after `switch`

Wayle connects to the system D-Bus name `org.freedesktop.NetworkManager`
*once*, at its own startup, and never retries. If that name isn't reachable at
that moment it marks the Network service dead for the whole session and drops
the module from the bar entirely:

```
wayle_shell::bootstrap: Network unavailable, error: dbus operation failed:
  org.freedesktop.DBus.Error.ServiceUnknown: The name is not activatable
module configured in bar layout but `network` service is unavailable … module will not appear
```

**Trigger confirmed:** `switch` / `nixos-rebuild` restarts
`NetworkManager.service` mid-session (journal: NM stopped+started at 08:24
today, ~21h after boot), and the wayle user service is also restarted by the
same switch and comes up ~1s *before* NM's D-Bus name is ready → race → Network
service dead. `nmcli` is unaffected because it opens a fresh D-Bus connection
every call.

- **Reboot fixes this**, because on a clean boot NM is up long before
  graphical-session.target starts wayle. **But it recurs on the next `switch`.**
- Workaround: `systemctl --user restart wayle` after any rebuild. Confirmed to
  bring the module back cleanly (no "not activatable").
- Durable fix options: report upstream (wayle should watch `NameOwnerChanged`
  and reconnect); or bind a wayle user-service restart to NM restarts.

### 1b. The actual "failed" on click = iwd cannot associate (NOT wayle)

When the module is alive and a saved network is clicked, wayle calls NM's
`ActivateConnection`; NM hands the connect to the **iwd** backend and iwd fails
it. Confirmed by replaying the *exact* `ActivateConnection` D-Bus call by hand
(wayle not involved) — it failed identically:

```
NetworkManager: device (wlan0): Activation: (wifi) Network.Connect failed:
  GDBus.Error:net.connman.iwd.Failed: Operation failed
iwd: event: connect-info, ssid: dev (✿◠‿◠), bss: 0e:ea:14:1f:f1:8a, signal: -59, load: 105/255
iwd: event: connect-failed, status: 1
```

This **rules out** the earlier theories: not the AP `specific_object` (passed
`/` and still failed), not a missing secret (NM profile has the PSK,
`psk-flags=0`). It is iwd failing the association/handshake (`status: 1`).

Key evidence it's the network/iwd, not wayle or the profile:
- Today iwd logged **48 `connect-failed` vs only 5 successful connects** —
  mostly failing regardless of who initiates.
- `dev (✿◠‿◠)` broadcasts from **6+ BSSIDs**, all locally-administered MACs
  (`0e:ea:14:*`, `62:22:32:*`) → a mesh / multi-AP network with roaming; iwd
  keeps picking BSSIDs whose handshake fails (`load: 105/255` suggests the AP
  is loaded / possibly band-steering/kicking).
- Because iwd occasionally succeeds, the stored PSK is correct.

So wayle's "failed" is **faithfully reporting a real connection failure**. The
reason interactive `nmcli` "works" is almost certainly retry behaviour: iwd
succeeds ~1-in-10, and you naturally re-run `nmcli` (or use
`nmcli device wifi connect --ask`, which forces a fresh scan + BSSID pick)
until one attempt lands. Wayle fires once and shows the failure with no retry.

Side effect: duplicate NM profiles (`dev (✿◠‿◠)` **and** `dev (✿◠‿◠) 1`, same
for `lan down under*`) from repeated add-and-activate fall-throughs. Cosmetic;
can be pruned with `nmcli connection delete <uuid>`.

**Networking config:** `nixos/features/networking/default.nix` — NetworkManager
frontend; the wifi backend is now a parameter (`wifiBackend`) chosen per host at
import. framebook passes `"wpa_supplicant"` (default is still `"iwd"`, which
nixbook uses). iwd's `EnableNetworkConfiguration = false`.

**Plan / status for 1b:**
- [x] Switched the backend: framebook now imports the networking feature with
      `wifiBackend = "wpa_supplicant"` (nixos/hosts/framebook/default.nix:39),
      which handles the roaming/multi-BSSID `dev (✿◠‿◠)` network more reliably
      than iwd did. nixbook still defaults to iwd. **Resolved** (monitor on the
      flaky network).
- [ ] Clean up duplicate ` 1` NM profiles (cosmetic).

## 2. No hibernate while charging (to allow overnight automatic updates)

**Goal:** When the laptop is plugged in / charging, do not hibernate (or
suspend-then-hibernate) on idle, so that scheduled overnight automatic updates
can run. On battery, keep the normal hibernate behaviour.

**Status:** Implemented (pending `switch` + overnight verification).

**What the machine actually does on idle:** not hibernate — it *suspends*, via
two independent paths. Both are now AC-aware so the machine stays awake on
mains power and the overnight update can run; both keep the old behaviour on
battery.

1. **Idle timeout (lid open)** — `hypridle` (home-manager/framebook.nix). The
   600s `on-timeout` no longer calls `systemctl suspend` directly; it calls a
   `suspend-unless-charging` script that scans `/sys/class/power_supply/*` and
   suspends only if no `Mains` supply is `online`. On AC it is a no-op (the 300s
   lock still fires). On battery it suspends as before.
2. **Lid close** — logind (nixos/hosts/framebook/default.nix):
   `services.logind.lidSwitchExternalPower = "lock"`. On AC, closing the lid
   locks the session but keeps the machine awake. On battery, `lidSwitch` is
   left at its default (`suspend`), so lid close still suspends.

**Auto-update job:** already in place — `system.autoUpgrade`
(nixos/hosts/framebook/default.nix) runs `dates = "daily"` (00:00 + up to 45min
randomised delay), `persistent = true`, `allowReboot = false`. With the above,
it now has an awake, on-AC window to run in overnight.

**To verify after `switch`:** on AC, leave idle > 10 min and close the lid —
machine should stay up (check `systemctl status systemd-suspend.service` shows
no recent suspend, and `journalctl -u nixos-upgrade` shows an overnight run).
On battery, idle/lid-close should still suspend.

## 3. Fingerprint unlock flaky after hibernate / long idle

**Symptom:** Fingerprint unlock on the lock screen is unreliable after the
machine has been asleep / away from the screen for a long time. (Not hibernate —
the machine *suspends*, s2idle; see issue #2.)

**Status:** Diagnosed — root cause is a **suspend-abort by the Bluetooth
controller**, not fprintd or the PAM stack. Fix not yet applied (options below).

**Diagnosis (from the journal):** reader is a **Goodix MOC Fingerprint Sensor**
(`libfprint` goodixmoc). hyprlock reads it over D-Bus directly and keeps a verify
loop active on the lock screen. The failure chain:

1. The Intel BT controller fails to suspend — `btintel_pcie … returns -16`
   (`-EBUSY`) → `PM: Some devices failed to suspend` → `systemd-sleep: Failed to
   put system to sleep. System resumed again: Device or resource busy`. This
   happened **30×** in a single boot; it is frequent, not rare.
2. The aborted suspend leaves the USB/SPI bus (and the Goodix sensor) in a dirty
   state. logind emits `PrepareForSleep(false)`; hyprlock immediately **restarts
   the fingerprint verify**, which hits the wedged sensor →
   `fprintd: Device reported an error during verify: transfer timed out`.
3. hyprlock classifies the timeout as `verify-unknown-error` and, on that class,
   **disables fingerprint auth for the rest of the lock session** ("Fingerprint
   auth disabled (unknown error)") → forced to type the password. One strike,
   no retry.

Evidence: every `transfer timed out` is preceded within ~2 s by a "Failed to put
system to sleep" abort. **Clean** suspends (`Finished System Suspend`) almost
always resume with working fingerprint (1 timeout out of ~6 clean resumes) — so
the fingerprint stack itself is fine; the BT suspend-abort is what breaks it.

Secondary notes:
- `Cannot run while suspended` logged at `PrepareForSleep(true)` is **harmless** —
  fprintd correctly cancelling the in-flight verify as the machine suspends.
- hyprlock v0.9.6 has `auth:fingerprint:retry_delay`, but it only retries soft
  statuses (`verify-retry-scan` etc.), **not** `verify-unknown-error`, so it
  won't by itself recover a `transfer timed out`.

**Confirmed upstream regression (checked 2026-10-30).** This is a known
`btintel_pcie` bug specific to **Intel Lunar Lake** (this laptop). The D-state
transition's "alive interrupt" times out; `btintel_pcie_set_dxstate()` falls
back to a **stale `boot_stage_cache`** (only the IRQ handler updates it), every
retry fails → `-EBUSY` → suspend aborts. Introduced by the suspend/resume
support commits (`e57362f4911b` / `88c6216a52ea`). Fix is **still in flight,
not merged** as of Sep 2026 (bluetooth-next PRs #699 → #728 → #822 → #831 →
#834; #834 closed-not-merged, to be resent as a combined S0ix/S3/S4 PM series).
No `stable` tag / mainline merge / 7.x backport found. Current kernel 7.2.8 (Sep
25 2026 build) predates any merge, so **`nix flake update` will not fix this
yet** — watch the PRs above and drop the workaround once the fix lands.

**Fix options (ranked):**
1. **Stop BT aborting suspend (root cause, interim workaround).** Drop/clear the
   BT controller before sleep so it can't return `-EBUSY` — e.g.
   `powerManagement.powerDownCommands` to `rfkill block bluetooth` (or
   `rmmod btintel_pcie`) pre-sleep and re-enable in `resumeCommands`. Trade-off:
   BT briefly off around each sleep. Remove when the upstream fix ships.
2. **Reset the sensor on resume** (`powerManagement.resumeCommands` →
   `systemctl restart fprintd`) as a belt-and-braces follow-up — but on its own
   it does not help the *current* lock session, because hyprlock has already
   given up by then.
3. Report hyprlock's one-strike-on-unknown-error behaviour upstream / request a
   retry on `verify-unknown-error`.

To re-capture after a failed unlock: `journalctl -b 0 | grep -iE
"btintel_pcie|Failed to put system to sleep|transfer timed out|fprint"`.
