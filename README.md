# dotfiles

A minimalist, keyboard-driven Linux setup built on **Debian (server base)**. No desktop environment — just the tools that matter. Everything is intentional: Catppuccin theming, Vim keybindings, local-first terminal workflows, and a clean Wayland compositor stack.

---

## Philosophy

- Start from Debian minimal (server ISO) — no GNOME, no KDE, no bloat
- Build up only what is needed, layer by layer
- Consistent Catppuccin theme switching across terminal, editor, desktop, and mail
- Keyboard-first workflow — mouse is optional
- Wayland-native where possible; XWayland only as fallback

---

## Stack

### Window System
| Tool | Role |
|------|------|
| [Sway](https://swaywm.org) | Tiling Wayland compositor (i3-compatible) |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [Rofi](https://github.com/davatorium/rofi) | App launcher + power menu |
| [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter) | Notification daemon + control center |
| [Kanshi](https://git.sr.ht/~emersion/kanshi) | Automatic display profiles |
| [Swaylock](https://github.com/swaywm/swaylock) | Screen locker |
| [Swaybg](https://github.com/swaywm/swaybg) | Wallpaper |

### Terminal & Shell
| Tool | Role |
|------|------|
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal (default) |
| [Ghostty](https://ghostty.org) | Alternative terminal |
| Bash | Shell with custom aliases and functions |
| [FZF](https://github.com/junegunn/fzf) | Fuzzy finder (Ctrl+R, Ctrl+T) |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement with icons |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [ranger](https://github.com/ranger/ranger) | Terminal file manager |
| [pass](https://www.passwordstore.org/) | Minimal GPG-backed password manager |
| [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Terminal system summary |

### Editors
| Tool | Role |
|------|------|
| [Neovim](https://neovim.io) | Primary editor (AppImage, always latest) |
| [LazyVim](https://lazyvim.org) | Neovim config framework |
| Vim | Fallback editor (vim-gtk3 + Vundle + Dracula) |

Neovim is configured with LSP support for C/C++ (clangd), Python (pylsp), Rust (rust-analyzer), and LaTeX (vimtex + Zathura).

### Development
| Tool | Role |
|------|------|
| GCC / G++ | C and C++ compilers |
| CMake + Ninja | Build system (standard for C/C++ projects) |
| Clangd | C/C++ language server (LSP) |
| GDB | Debugger |
| Valgrind | Memory error detector |
| Rust (rustup) | Systems programming language + rust-analyzer |
| Python 3 | Scripting + scientific computing |
| Node.js (nvm) | JavaScript runtime (required by some LSP servers) |
| Lua + LuaRocks | Scripting (used by Neovim internals) |

### Scientific Writing
| Tool | Role |
|------|------|
| [TeXLive](https://tug.org/texlive/) (full) | Complete LaTeX distribution |
| [Zathura](https://pwmt.org/projects/zathura/) | Minimal PDF viewer with Vim keybindings |
| [Gnuplot](http://www.gnuplot.info) | Data visualization and plotting |
| [GNU Octave](https://octave.org) | MATLAB-compatible scientific computing |

### Applications
| Tool | Role |
|------|------|
| Firefox | Browser (from Mozilla's official apt repo) |
| LibreWolf | Privacy-hardened Firefox fork |
| Thunderbird | Email client |
| Spotify | Music |
| GitHub Desktop | Git GUI |
| VSCodium | Telemetry-free VS Code |
| NeoMutt | Terminal email client |
| [mbsync](https://isync.sourceforge.io/) | Sync IMAP mail to local Maildir |
| [msmtp](https://marlam.de/msmtp/) | Send mail through SMTP |
| Lazygit | Terminal Git UI |

---

## Structure

```
dotfiles/
├── install.sh          ← interactive installer
├── layers/             ← install scripts, run in order
│   ├── 00-sudo.sh      ← add user to sudoers (run as root first)
│   ├── 01-base.sh      ← apt essentials, Python, Node (nvm), Rust
│   ├── 02-cli.sh       ← Neovim, fzf, ranger, eza, lazygit, bat, pass, fastfetch, vim
│   ├── 03-wayland.sh   ← sway stack, kitty, rofi, swaync, grim, swaylock, kanshi
│   ├── 04-fonts.sh     ← JetBrainsMono & SpaceMono Nerd Fonts
│   ├── 05-dev.sh       ← gcc, cmake, ninja, clangd, gdb, rust-analyzer, lua
│   ├── 06-apps.sh      ← firefox, librewolf, spotify, thunderbird, vscodium, neomutt, mbsync, msmtp
│   ├── 07-grub.sh      ← GRUB bootloader theme
│   └── 08-octave.sh    ← GNU Octave with symbolic & statistics packages
├── dots/
│   └── link.sh         ← symlinks everything to the right place
├── config/             ← ~/.config/* (sway, waybar, nvim, rofi, ...)
│   ├── fastfetch/      ← Fastfetch config (Hyprdots-inspired layout)
│   ├── isync/          ← mbsync IMAP config
│   ├── msmtp/          ← SMTP sending config
│   ├── mutt/           ← NeoMutt config + Catppuccin themes
│   ├── kitty/          ← Kitty config + Catppuccin themes
│   ├── rofi/           ← Rofi config + Catppuccin themes
│   ├── swaync/         ← SwayNotificationCenter config + CSS
│   ├── waybar/         ← Waybar config + Catppuccin themes
│   └── sway/hosts/     ← per-machine Sway settings
├── home/               ← ~/.*  (bashrc, bash_aliases, vimrc)
├── bin/                ← ~/.local/bin/ (changeTheme, sync-mail, mount-sd, wallpaper, nextcloud, ...)
└── assets/
    ├── wallpapers/     ← wallpapers
    └── grub/           ← GRUB theme
```

---

## Installation

On a fresh Debian server install:

```bash
# 1. Clone the repo
git clone https://github.com/VhI3/dotfiles.git ~/dotfiles

# 2. Run the installer
cd ~/dotfiles
./install.sh
```

The installer presents a menu. Run layers in order (0 → 8) on a fresh machine, or pick individual layers to update specific tools. Run `l` at any time to symlink configs without reinstalling anything.

Linking also:

- runs the Sway host selector automatically
- initializes the shared Catppuccin theme files
- links helper scripts into `~/.local/bin`
- links `~/.config/swaync` for notifications

If the current hostname matches a file in `config/sway/hosts/`, it becomes the active per-machine Sway config.

Example:

```bash
~/.local/bin/select-sway-host laptop
```

---

## Host-Specific Sway Setup

Shared Sway behavior lives in `config/sway/config`.

Machine-specific settings such as:

- monitor layout / scaling
- workspace-to-output mapping
- wallpaper path
- personal autostart programs

belong in `config/sway/hosts/<hostname>.conf`.

Current host profiles:

- `debian`
- `laptop`

To add another machine:

```bash
cp config/sway/hosts/laptop.conf config/sway/hosts/workstation.conf
~/.local/bin/select-sway-host workstation
```

The generated file `config/sway/host.local.conf` is local state and is intentionally not tracked by git.

For the current `debian` host, monitor switching is handled dynamically by `kanshi`:

- if `HDMI-A-2` is connected, use the external monitor only
- otherwise, use the laptop screen only

That logic lives in `config/kanshi/config`, while the Sway host file keeps machine-specific autostarts and wallpaper commands.

For the current `debian` host, those autostarts include:

- `nm-applet`
- `nextcloud` via a local wrapper script
- `thunderbird`
- `pcloud`
- `indicator-sound-switcher`

---

## Theme

**Catppuccin** throughout — Kitty, Neovim, NeoMutt, Ranger, Rofi, Sway, Swaylock, Waybar, Zathura, eza, and the notification stack.

Theme switching is unified through:

- `changeTheme`
- `changeTheme.sh`
- `Mod+Shift+t` in Sway

Available flavours:

- Latte
- Frappe
- Macchiato
- Mocha

Font: **JetBrainsMono Nerd Font** (terminals, status bar, editors).

Note: NeoMutt follows the official Catppuccin NeoMutt setup, which ships a Latte variant and one shared dark variant for Frappe, Macchiato, and Mocha.

Waybar and SwayNotificationCenter keep their own config/style files, but both are part of the same desktop theme direction.

---

## Mail

Mail is configured as a local-first terminal workflow:

- `neomutt` for reading and composing
- `mbsync` for syncing IMAP to `~/Mail`
- `msmtp` for SMTP sending
- `pass` for secret storage

Config locations:

- `config/mutt/muttrc`
- `config/isync/mbsyncrc`
- `config/msmtp/config`

Helper commands:

- `mail` → start NeoMutt
- `sync-mail` → sync mailboxes
- `mbs` → run mbsync directly

Pass entries expected by the mail setup:

- `mail/mailbox.org/imap`
- `mail/mailbox.org/smtp`

---

## Helpers

Useful local scripts linked into `~/.local/bin`:

- `changeTheme` → switch the shared Catppuccin flavour
- `kitty-theme` → compatibility wrapper for the shared theme switcher
- `sync-mail` → sync NeoMutt mailboxes
- `mount-sd` → mount a removable SD card to `/mnt/sdcard`
- `notify-media` → show song/artist notifications for media transport keys
- `nextcloud` → start the Nextcloud AppImage with the XWayland/Qt wrapper needed on Sway
- `cleanup-pcloud-metadata` → move old Nextcloud/ownCloud sync metadata out of `~/pCloudDrive`
- `select-sway-host` → choose the active host-specific Sway file
- `wallpaper` → set wallpaper with fallback behavior
- `update-nvim` → refresh the Neovim AppImage

`mount-sd` accepts an explicit block device like `mount-sd /dev/mmcblk0p1`, but will also mount to `/mnt/sdcard` with the default helper path.

`notify-media` is used by the Sway media-key bindings so play/pause/next/previous show a desktop notification with the current track.

`nextcloud` exists because the AppImage ships only the `xcb` Qt platform plugin, so on Sway it is launched through XWayland via `QT_QPA_PLATFORM=xcb`.

`cleanup-pcloud-metadata` is a safe migration helper: it only moves stale `.nextcloudsync.log`, `.owncloudsync.log`, and `.sync_*.db*` files into a timestamped backup folder.

---

## Notifications

Notifications are handled by **SwayNotificationCenter** (`swaync`) instead of Mako or Dunst.

- `swaync` starts from Sway
- `Mod+Shift+n` toggles the notification center
- Waybar shows a notification icon module with left-click to open and right-click to toggle Do Not Disturb

Config lives in:

- `config/swaync/config.json`
- `config/swaync/style.css`

If you previously had `dunst` installed, the Wayland layer tries to disable it so `org.freedesktop.Notifications` is owned by `swaync`.

---

## Cloud Apps

- `nextcloud` is started from the host-specific Sway config through `~/.local/bin/nextcloud`
- `pcloud` is started from the current `debian` host profile

The pCloud helper `cleanup-pcloud-metadata` is intended for cleaning migrated Nextcloud/ownCloud sync state out of `~/pCloudDrive` without touching normal documents.

---

## Key Bindings (Sway)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (kitty) |
| `Mod+d` | App launcher (rofi) |
| `Mod+Shift+t` | Open Catppuccin theme picker |
| `Mod+Shift+n` | Toggle notification center (`swaync`) |
| `Mod+Shift+e` | Power menu (rofi) |
| `Mod+Shift+x` | Lock screen (swaylock) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+f` | Fullscreen |
| `Mod+r` | Resize mode |
| `Caps Lock` | Escape (remapped) |
| `Print` | Screenshot (grim) |
| `XF86AudioPlay / Pause / Next / Prev` | Spotify transport with track notifications |
