# nixos-config

Personal NixOS + [Home Manager](https://github.com/nix-community/home-manager) configuration for an **ASUS Zephyrus** laptop.

## Hardware

| Component | Detail |
|-----------|--------|
| **Model** | ASUS Zephyrus (2024) |
| **CPU** | Intel Core i7-13620H |
| **GPU** | NVIDIA GeForce RTX 4060 (PRIME offload) |
| **Display** | 2560×1600 @ 240Hz (Thermotrex TL160ADMP03-0) |
| **Kernel** | Linux 6.18 (NixOS unstable) |

## Features

- **Hyprland** — Wayland compositor with animations, blur, and gaps
- **NVIDIA PRIME** — iGPU by default, NVIDIA for heavy workloads
- **Instant power profiles** — 240Hz + eye candy on AC, 60Hz + minimal on battery (udev-driven, no polling)
- **PCIe ASPM** — `performance` on AC, `powersupersave` on battery (kernel-level)
- **Declarative dotfiles** — all configs in `dotfiles/`, managed by Home Manager (symlinked from Nix store)
- **System services** — asusd (fan control, charge limit), Tailscale, zram swap
- **Auto-git** — `rebuild` script syncs → rebuilds → commits → pushes in one command

## Structure

```
├── configuration.nix    # NixOS system config (kernel, drivers, services, udev)
├── home.nix             # Home Manager user config (packages, dotfiles, systemd)
├── hardware-configuration.nix  # Auto-generated — NOT tracked (machine-specific)
├── dotfiles/
│   ├── hypr/            # Hyprland (WM), hypridle, hyprpaper
│   ├── waybar/          # Status bar
│   ├── ghostty/         # Terminal emulator
│   ├── nvim/            # Neovim (vim-plug, vimtex, lean.nvim)
│   ├── gammastep/       # Blue light filter
│   ├── htop/            # Process monitor
│   ├── yazi/            # Terminal file manager
│   ├── zathura/         # PDF viewer
│   ├── Code/            # VSCode keybindings
│   ├── scripts/         # Utility scripts (rebuild, compiler, texnow, etc.)
│   ├── clinerules       # Zoo Code AI rules
│   └── memory-strategy.md
└── .gitignore           # Ignores home-directory clutter, secrets, Nix artifacts
```

## Usage on a new machine

```bash
# 1. Clone this repo
git clone git@github.com:ganddoffcha/nixos-config.git /etc/nixos

# 2. Generate your hardware config
nixos-generate-config --root /etc/nixos
# This creates /etc/nixos/hardware-configuration.nix (machine-specific, gitignored)

# 3. Edit configuration.nix — update hostName, remove NVIDIA section if no dGPU

# 4. Build and switch
nixos-rebuild switch
```

After the first build, use `rebuild` for subsequent changes — it syncs configs to `/etc/nixos/`, rebuilds, commits, and pushes automatically.

```bash
rebuild          # nixos-rebuild switch + git auto-push
rebuild boot     # nixos-rebuild boot  + git auto-push
rebuild test     # nixos-rebuild test  + git auto-push
```

## Power profiles

Plug/unplug your charger — the system switches instantly via udev:

| State | Refresh | Animations | Blur | Shadows | PCIe ASPM |
|-------|---------|------------|------|---------|------------|
| **AC** | 240Hz | on | on | on | performance |
| **Battery** | 60Hz | off | off | off | powersupersave |

The 30-second timer is a fallback only. Kernel udev events handle the instant switch.
