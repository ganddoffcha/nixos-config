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
- **Editor**: neovim (nvim), vscode, emacs also installed
- **Browser**: brave (primary), chromium, qutebrowser also installed
- **Filesystem root**: ext4 on nvme1n1p2
- **Boot**: systemd-boot, EFI
