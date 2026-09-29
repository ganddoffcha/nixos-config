# System Topology — zephyrus

> Auto-injected context for Zoo. Documents the physical and logical layout of the system so Zoo doesn't make wrong assumptions about where files live, how the build pipeline works, or what hardware is present.

## Hardware

| Component | Detail |
|-----------|--------|
| Machine | ASUS ROG Zephyrus G16 (GU603VV, BIOS GU603VV.315) |
| CPU | Intel Core i7-13620H (16 threads) |
| GPU | Intel iGPU (i915, drives eDP-1) + NVIDIA AD107M / RTX 4060 (PRIME offload) |
| Disk 1 (nvme0n1) | **Linux**: nvme0n1p1 = /boot (vfat 1G), nvme0n1p2 = / (ext4 930.5G) |
| Disk 2 (nvme1n1) | **Windows 11**: nvme1n1p3 = BitLocker (926.3G), p1/p6 = ESPs, p2 = MSR, p4/p5 = ntfs |
| RAM | 30G (zram swap ~7.7G) |
| Swap | `/swapfile` (8G) on nvme0n1p2, `resume_offset=210616320` |
| Display | 2560×1600 @ 240Hz (186 DPI) |

## NixOS Config Topology (CRITICAL)

```
/home/gc/                          ← Git repo (nixos-config), SOURCE OF TRUTH, flake root
├── flake.nix                      ← Flake: nixosConfigurations.zephyrus (nixpkgs, home-manager, catppuccin, nixos-hardware)
├── flake.lock                     ← Pinned flake inputs
├── configuration.nix              ← NixOS system config (boot, services, udev, thermal, asusd)
├── home.nix                       ← Home-manager user config (packages, dotfiles, systemd services)
├── hardware-configuration.nix     ← Auto-generated (hardware specifics)
├── dotfiles/
│   ├── hypr/hyprland.lua          ← Hyprland WM config (Lua, migrated 2026-09-28)
│   ├── hypr/hypridle.conf         ← Idle daemon (+ hypridle-ac.conf)
│   ├── hypr/hyprlock.conf         ← Lock screen
│   ├── scripts/rebuild            ← Rebuild script (flake-based)
│   └── ...
└── .git/                          ← Remote: git@github.com:ganddoffcha/nixos-config.git
```

**Rule: NEVER edit `/etc/nixos/` directly.** The system is **flake-based** — `nixos-rebuild` reads directly from the flake at `/home/gc`, not from `/etc/nixos/`. Always edit `/home/gc/` (the git repo), then run `rebuild`.

> Note: the flake only sees **git-tracked** files. A new (untracked) file must be `git add`-ed *before* rebuilding or `nixos-rebuild` fails with "Path ... is not tracked by Git".

## Build Pipeline

```
rebuild [-m "message"] [switch|boot|test|dry-build]
  ├─ 1. sudo nixos-rebuild <action> --flake ~/#zephyrus
  ├─ 2. git add configuration.nix home.nix dotfiles/ flake.lock hardware-configuration.nix .gitignore
  ├─ 3. git commit (-m custom, or auto "nixos-rebuild: YYYY-MM-DD-HHMM")
  └─ 4. git push origin main
```

## Key Configuration Decisions

- **WM**: Hyprland (Lua config `hyprland.lua`, launched via uwsm from `.zprofile`)
- **Shell**: zsh with starship, zoxide, fzf, atuin
- **Terminal**: kitty (primary), ghostty (secondary) — alacritty removed 2026-07-07
- **Editor**: neovim (Lua config, vimtex, lean.nvim) + VSCode — emacs removed 2026-07-07
- **Browser**: brave (primary), qutebrowser — chromium removed 2026-07-07
- **Launcher**: bemenu (runtime theming via wrapper scripts)
- **Filesystem**: ext4 on nvme0n1p2
- **Boot**: systemd-boot, EFI
- **Config style**: Flake-based (`nix.settings.experimental-features = ["nix-command" "flakes"]`)
- **Home-manager**: integrated as NixOS module via the flake
- **Theme**: Catppuccin Mocha + blue accent via catppuccin/nix (no runtime theme switching)
- **Charge limit**: 80% via asusd (`environment.etc."asusd/asusd.ron"`, mode 0644)
- **Auto-upgrade**: `system.autoUpgrade` flake-based (`github:ganddoffcha/nixos-config#zephyrus`)
- **Hibernation**: lid-close → hibernate, resume from /swapfile (resume_device + resume_offset)
- **Sleep**: S3 deep (mem_sleep_default=deep)

## Power & Thermal Architecture

Complex subsystem — do not break without understanding:

```
AC adapter event (udev) → thermal-hotplug (systemd, self-detecting)
  → applies thermal caps: RAPL PL1/PL2, EPP, platform_profile, PCIe ASPM
  → touches /tmp/power-supply-event
  → auto-refresh-instant.path (user) → auto-refresh.service
  → ~/scripts/auto-refresh
  → monitor refresh 240Hz (AC) / 60Hz (battery) + Hyprland eye-candy toggle

Fallbacks:
  - thermal-hotplug-poll.timer (system, 30s) — udev can't see AC plug-in on this ASUS
  - auto-refresh.timer (user, 30s)
Post-rebuild: home.activation runs auto-refresh (Hyprland config reload can reset refresh rate)
```

- **AC detection MUST use battery EC status** (`Charging`/`Full`) as a fallback — `ADP0 online` is stuck at 0 on this ASUS (ACPI AC driver always reports offline even when charging), and the kernel emits no uevent for the Discharging→Charging transition.
- **AC profile**: PL1=45W, PL2=115W, governor=`performance`, EPP=`balance_performance`, platform_profile=`balanced`.
- **Battery profile**: PL1=20W, PL2=35W, governor=`powersave`, EPP=`power`, platform_profile=`quiet`.
- **asusd**: `platform_profile_on_ac = Balanced` (NOT Performance — Performance triggers the firmware PL1=200W MSR write). asusd handles charge cap + fan curves.
- **DO NOT switch to `performance` platform profile** — firmware sets PL1 back to 200W and thermal-throttles. Use `balanced` + RAPL sysfs caps.
- Note: on AC the EPP sysfs value reads `performance` (intel_pstate forces it under the `performance` governor) — expected and harmless; EPP only matters on battery.

## Rules Zoo Must Follow

1. **NEVER edit `/etc/nixos/` directly** — the system is flake-based; edits there have no effect. Edit `/home/gc/` (git repo) then `rebuild`.
2. **`git add` new files before rebuild** — the flake only sees git-tracked files.
3. **VSCode configs must NOT be home-manager managed** — Nix store symlinks are read-only. `settings.json`/`keybindings.json` live at `~/.config/Code/User/` as real files.
4. **Use `rebuild`, not raw `nixos-rebuild`** — it handles git commit + push.
5. **Ask before sudo** — Zoo must explicitly ask before running any sudo command.
6. **RON configs use `//` comments, never `#`** — `#` is a Nix comment, invalid inside RON strings (e.g. asusd.ron).

## Known Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Editing /etc/nixos/ directly | Changes don't apply (flake ignored) | Edit /home/gc/ instead |
| New untracked file referenced by flake | "Path ... is not tracked by Git" | `git add` it first |
| `#` comment inside a RON string | asusd resets to defaults (charge cap 100) | Use `//` or keep comments in Nix |
| VSCode settings in home-manager | VSCode can't write settings | Keep them out of home.nix |
| Wrong power supply device for AC detection | Always thinks on battery | Use battery EC status (Charging/Full) fallback |
| Forgetting resume_offset after swapfile recreation | Hibernation fails | `filefrag -v /swapfile`, update configuration.nix |
| Hyprland config reload during rebuild | Refresh rate resets | auto-refresh runs in home.activation |

## User Preferences

- **Launcher**: bemenu (explicitly dislikes wofi)
- **Workspace**: `/home/gc/Desktop/` is the active VSCode workspace; `~/` is the git repo / source of truth
- **Editor**: neovim with Lua config
- **Git**: descriptive commit messages preferred over auto-generated timestamps
- **Memory**: expects Zoo to proactively remember system details without being reminded
- **Power policy**: plugged in → performance; on battery → power save; charge cap 80%
