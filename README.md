# nixos-config

Personal NixOS + [Home Manager](https://github.com/nix-community/home-manager) configuration for an **ASUS Zephyrus** laptop. Flake-based, fully declarative, single-command reproducible.

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
- **Stylix** — system-wide base16 theming (Catppuccin, Everforest, Nord, 20 curated themes)
- **Instant theme switching** — `theme <name>` applies colours to all apps in 0.3s (no rebuild needed)
- **Wallpaper auto-match** — `wallpaper <image>` picks the best-matching theme automatically
- **Instant power profiles** — 240Hz + eye candy on AC, 60Hz + minimal on battery (udev-driven)
- **PCIe ASPM** — `performance` on AC, `powersupersave` on battery (kernel-level)
- **Hibernation on lid-close** — suspend-to-disk via systemd-logind
- **Declarative dotfiles** — configs in `dotfiles/`, managed by Home Manager
- **bemenu** — wayland-native app launcher with dynamic theming
- **Auto-git** — `rebuild` script syncs → rebuilds → commits → pushes in one command
- **POSIX shell** — `/bin/sh` is dash, all scripts are POSIX-clean

## Structure

```
├── flake.nix             # Flake inputs & outputs (nixpkgs, home-manager, stylix, nixos-hardware)
├── flake.lock            # Pinned flake inputs
├── configuration.nix     # NixOS system config (kernel, drivers, services, udev, stylix)
├── home.nix              # Home Manager user config (packages, dotfiles, systemd services)
├── hardware-configuration.nix  # Auto-generated — machine-specific
├── dotfiles/
│   ├── hypr/             # Hyprland (WM), hypridle, hyprlock, hyprpaper
│   ├── waybar/           # Status bar (config + CSS)
│   ├── ghostty/          # Terminal emulator (GPU-accelerated)
│   ├── kitty/            # Terminal emulator (fallback)
│   ├── nvim/             # Neovim (lazy.nvim, vimtex, lean.nvim, lsp)
│   ├── mako/             # Notification daemon
│   ├── gammastep/        # Blue light filter
│   ├── yazi/             # Terminal file manager
│   ├── zathura/          # PDF viewer
│   ├── mpv/              # Media player (vulkan, vaapi)
│   ├── qutebrowser/      # Keyboard-driven browser
│   ├── Code/             # VSCode keybindings & settings
│   ├── scripts/          # Utility scripts (see below)
│   ├── wallpapers/       # 12 wallpapers (picsum + personal)
│   ├── fonts/            # Google Sans TTF files
│   ├── curated-themes    # 20 hand-picked base16 themes
│   ├── current-theme     # Active theme name (imperative, runtime-editable)
│   ├── mimeapps.list     # XDG MIME type associations
│   ├── clinerules        # Zoo Code AI rules
│   └── memory-strategy.md
├── README.md
├── SYSTEM.md             # Detailed system topology (for AI context)
└── .gitignore
```

## Quick start (new machine)

```bash
# 1. Clone this repo
git clone git@github.com:ganddoffcha/nixos-config.git ~/nixos-config
cd ~/nixos-config

# 2. Generate hardware config
nixos-generate-config --root .

# 3. Edit configuration.nix — update hostName, remove NVIDIA section if no dGPU

# 4. Build and switch (flake-based)
sudo nixos-rebuild switch --flake .#zephyrus

# 5. Rebuild for subsequent changes
rebuild              # switch + git auto-push
rebuild -m "msg"     # with custom commit message
rebuild boot         # build + set as boot default
rebuild test         # build without activating
```

## Scripts

All scripts in `~/scripts/` (POSIX sh, `-h` for help):

| Script | Purpose |
|--------|---------|
| `rebuild` | NixOS rebuild + git commit + push |
| `theme` | Instant theme switcher (runtime, no rebuild) |
| `wallpaper` | Wallpaper setter + auto theme matcher |
| `compiler` | Multi-format document compiler (LaTeX, groff, md, etc.) |
| `texnow` | Create new LaTeX project from template |
| `opout` | Open compiled output (PDF → zathura) |
| `getcomproot` | Find root file of multi-file projects |
| `auto-refresh.sh` | Power profile auto-switcher (systemd service) |
| `toggle_touchpad` | Toggle laptop touchpad on/off |
| `hotspot` | Start Wi-Fi hotspot |
| `sp` | Launch Spotify (Wayland native) |
| `yazi_picker` | File picker via yazi + ghostty |
| `dmenupass` | bemenu-based sudo password prompt |
| `bemenu` | bemenu wrapper (sources runtime theme colours) |
| `bemenu-run` | bemenu-run wrapper (dynamic theming) |

## Theming

Themes are managed by [Stylix](https://github.com/danth/stylix) using base16 colour schemes. The active theme is stored in `dotfiles/current-theme`.

```bash
theme                  # show current theme
theme -l               # list curated themes (20 hand-picked)
theme -a               # list all 303 available themes
theme -p <name>        # preview theme colours in terminal
theme -P               # interactive bemenu picker + apply
theme <name>           # switch instantly (no rebuild)
```

Theme switching is instant — config files use `{{base00}}`…`{{base0F}}` placeholders that are substituted at runtime. Apps themed: Hyprland, Waybar, Kitty, Ghostty, Mako, Neovim, Yazi, bemenu.

GTK and Starship follow the theme on next `nixos-rebuild` (Stylix handles these at build time).

```bash
wallpaper                     # list available wallpapers
wallpaper <image>             # set wallpaper + auto-match best theme
wallpaper <image> <theme>     # set wallpaper + specific theme
wallpaper -m <image>          # show best-matching themes (ranked)
```

## Power profiles

Plug/unplug your charger — the system switches instantly via udev:

| State | Refresh | Animations | Blur | Shadows | PCIe ASPM |
|-------|---------|------------|------|---------|------------|
| **AC** | 240Hz | on | on | on | performance |
| **Battery** | 60Hz | off | off | off | powersupersave |

The 30-second timer is a fallback only. Kernel udev events handle the instant switch.

## Hibernation

Lid close → hibernate (suspend-to-disk). Resume from `/swapfile` on root partition. Configured via `boot.resumeDevice` + `resume_offset` kernel param + `logind` lid switch handlers.
