# System Topology — zephyrus

> Auto-injected context for Zoo. Documents the physical and logical layout of the system so Zoo doesn't make wrong assumptions about where files live, how the build pipeline works, or what hardware is present.

## Hardware

| Component | Detail |
|-----------|--------|
| Machine | ASUS Zephyrus (laptop) |
| CPU | Intel (kvm-intel module) |
| GPU | Intel iGPU + NVIDIA dGPU |
| Disk 1 (nvme0n1) | Multi-partition (Windows? data) |
| Disk 2 (nvme1n1) | **Linux root**: nvme1n1p2 (ext4, UUID `0e34ea3e-...`), nvme1n1p1 (/boot) |
| RAM | Has zram swap (25% of RAM) |
| Swap | `/swapfile` (8GB) on nvme1n1p2, resume_offset=210616320 |

## NixOS Config Topology (CRITICAL)

```
/home/gc/                          ← Git repo (nixos-config), SOURCE OF TRUTH
├── configuration.nix              ← System config (boot, services, hardware)
├── home.nix                       ← Home-manager user config (packages, dotfiles)
├── dotfiles/                      ← All declarative config files
│   ├── hypr/hyprland.conf         ← Hyprland WM config
│   ├── hypr/hypridle.conf         ← Idle daemon (suspend/hibernate timers)
│   ├── scripts/rebuild            ← THE rebuild script — syncs ~ → /etc/nixos, then nixos-rebuild, then git commit+push
│   └── ...
└── .git/                          ← Remote: git@github.com:ganddoffcha/nixos-config.git

/etc/nixos/                        ← TARGET (managed by rebuild script, DO NOT EDIT DIRECTLY)
├── configuration.nix              ← Copied FROM /home/gc/configuration.nix by rebuild script
├── home.nix                       ← Copied FROM /home/gc/home.nix by rebuild script
└── dotfiles/                      ← Copied FROM /home/gc/dotfiles/ by rebuild script
```

**Rule: NEVER edit `/etc/nixos/` directly.** Always edit `/home/gc/` (the git repo), then run `rebuild` which syncs → builds → commits → pushes.

## Build Pipeline

```
rebuild [-m "message"]
  ├─ 1. sudo cp ~/configuration.nix → /etc/nixos/configuration.nix
  ├─ 2. sudo cp ~/home.nix → /etc/nixos/home.nix
  ├─ 3. sudo cp -r ~/dotfiles/* → /etc/nixos/dotfiles/
  ├─ 4. sudo nixos-rebuild switch
  ├─ 5. git add configuration.nix home.nix dotfiles/ .gitignore
  ├─ 6. git commit (-m custom or auto "nixos-rebuild: YYYY-MM-DD-HHMM")
  └─ 7. git push origin main
```

## Key Configuration Decisions

- **Launcher**: bemenu (replaced wofi 2026-07-07)
- **Lid close**: hibernate (HandleLidSwitch=hibernate, both battery and AC)
- **Hibernation**: resume from /swapfile on root partition (resume_device + resume_offset)
- **Sleep**: S3 deep sleep (mem_sleep_default=deep)
- **Power profiles**: auto-refresh script switches monitor refresh rate on AC state change (udev-triggered)
- **Shell**: zsh with starship, zoxide, fzf, atuin
- **WM**: Hyprland (launched via uwsm from .zprofile)
- **Terminal**: ghostty (primary), alacritty, kitty also installed
- **Editor**: neovim (nvim, init.lua migrated from init.vim 2026-07-06), vscode, emacs also installed
- **Browser**: brave (primary), chromium, qutebrowser also installed
- **Filesystem root**: ext4 on nvme1n1p2
- **Boot**: systemd-boot, EFI
- **Config style**: Old-style NixOS config (no flake.nix at repo root), despite `nix.settings.experimental-features = ["nix-command" "flakes"]`
- **Home-manager**: Integrated as NixOS module (`<home-manager/nixos>` import), NOT standalone

## Power Profile Auto-Refresh System

Complex subsystem — do not break without understanding:

```
AC adapter event (udev)
  → /etc/udev/rules.d/... matches power_supply subsystem
  → Sets PCIe ASPM policy + touches /tmp/power-supply-event (chown gc:users)
  → systemd user path unit "auto-refresh-instant.path" watches /tmp/power-supply-event
  → Triggers auto-refresh.service (oneshot)
  → Runs ~/scripts/auto-refresh.sh
  → Queries AC state via /sys/class/power_supply/ADP0/online (Mains-type, NOT USB!)
  → Sets monitor refresh rate: 240Hz on AC, 60Hz on battery
  → Reloads Hyprland config to apply

Fallback: systemd user timer polls every 30s (in case udev rule misses an event)
Post-rebuild: home.activation runs auto-refresh.sh after every rebuild (Hyprland config reloads can reset refresh rate)
```

**Critical detail**: ADP0 is the AC adapter (type=Mains). A previous bug used the wrong power supply device (USB-C/Battery-type) which always reported offline.

## Rebuild Script Details

Located at `dotfiles/scripts/rebuild`. Key behaviors:

- **`git add` list is hardcoded**: `configuration.nix home.nix dotfiles/ .gitignore`. New top-level files (e.g., README.md, flake.nix) will NOT be auto-staged by `rebuild`. Must `git add` them manually.
- **Supports `-m` flag** (added 2026-07-07): `rebuild -m "descriptive message"` for custom commit messages
- **Old comment says "Managed by home-manager — do not edit directly"** — this is misleading. The file is in `dotfiles/scripts/` which IS home-manager managed, but editing the source in the git repo is correct. The comment refers to not editing the symlinked copy in the Nix store.

## Rules Zoo Must Follow

1. **NEVER edit `/etc/nixos/` directly** — edits will be clobbered by `rebuild`'s sync step. Always edit `/home/gc/` (git repo).
2. **VSCode configs must NOT be home-manager managed** — Nix store symlinks are read-only. VSCode writes to settings.json/keybindings.json at runtime. They live at `~/.config/Code/User/` and are NOT in home.nix. (Removed from home-manager session k, 2026-07-06.)
3. **Use `rebuild` script, not raw `nixos-rebuild`** — ensures sync → build → commit → push pipeline.
4. **Test hibernation with `systemctl hibernate` before trusting lid-close** — resume_offset must be correct or system won't wake.
5. **ADP0 is the AC adapter** — for any power-sensing code, use `/sys/class/power_supply/ADP0/online` (type=Mains), not other power supplies.

## Known Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Editing /etc/nixos/ directly | Changes vanish on next rebuild | Edit /home/gc/ instead |
| Adding new top-level file to repo | Not committed by rebuild script | `git add` manually, then `rebuild` |
| VSCode settings in home-manager | VSCode can't write settings, errors on start | Keep them out of home.nix, manage manually or via VSCode sync |
| Wrong power supply device for AC detection | auto-refresh always thinks on battery | Use ADP0 (Mains-type), not BAT0/USB |
| Forgetting resume_offset after swapfile recreation | Hibernation fails silently | Check with `filefrag -v /swapfile`, update configuration.nix |
| Hyprland config reload during rebuild | Monitor refresh rate resets to default | auto-refresh.sh runs in home.activation post-rebuild |

## Pending / Known Issues

- None currently open (as of 2026-07-07 session l)
- Historical: `git remote -v` vs `git remote -q` bug in rebuild script — FIXED (was using `-q` which doesn't exist, now `-v`)

## User Preferences

- **Launcher**: bemenu (explicitly dislikes wofo)
- **Workspace**: `~/` is the preferred directory (moved from `~/Desktop/` session d, 2026-07-06)
- **Editor**: neovim with Lua config
- **Git**: descriptive commit messages preferred over auto-generated timestamps
- **Memory**: expects Zoo to proactively remember system details without being reminded
