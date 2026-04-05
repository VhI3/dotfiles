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
| [SDDM](https://github.com/sddm/sddm) | Optional display manager / login screen |
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
│   ├── 07-grub.sh      ← Catppuccin GRUB theme installer
│   ├── 08-octave.sh    ← GNU Octave with symbolic & statistics packages
│   └── 09-sddm.sh      ← SDDM + Catppuccin login theme installer
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
├── bin/                ← ~/.local/bin/ (changeTheme, sync-mail, mount-sd, setup-epos, focus-or-launch, matlab-sway, wallpaper, ...)
└── assets/
    └── wallpapers/     ← wallpapers
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

The installer presents a menu. Run layers in order (0 → 9) on a fresh machine, or pick individual layers to update specific tools. Run `l` at any time to symlink configs without reinstalling anything.

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

To install the Catppuccin GRUB theme directly:

```bash
./layers/07-grub.sh
```

To pick a different flavor:

```bash
GRUB_THEME_FLAVOUR=macchiato ./layers/07-grub.sh
```

Available GRUB flavours:

- `latte`
- `frappe`
- `macchiato`
- `mocha`

To install the Catppuccin SDDM theme directly:

```bash
./layers/09-sddm.sh
```

To pick a different flavour and accent:

```bash
SDDM_THEME_FLAVOUR=macchiato SDDM_THEME_ACCENT=blue ./layers/09-sddm.sh
```

Available SDDM flavours:

- `latte`
- `frappe`
- `macchiato`
- `mocha`

Available SDDM accents:

- `rosewater`
- `flamingo`
- `pink`
- `mauve`
- `red`
- `maroon`
- `peach`
- `yellow`
- `green`
- `teal`
- `sky`
- `sapphire`
- `blue`
- `lavender`

Note: upstream recommends running the SDDM greeter on Wayland if the Catppuccin theme renders incorrectly on X11.

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

For the current `debian` host, those autostarts include desktop helpers like `nm-applet`, `thunderbird`, `pcloud`, and audio utilities.

---

## Theme

**Catppuccin** throughout — Kitty, Neovim, NeoMutt, Ranger, Rofi, Sway, Swaylock, Waybar, Zathura, eza, SDDM, and the notification stack.

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

Boot/login theming is handled separately through the install layers:

- `07-grub.sh` for GRUB
- `09-sddm.sh` for SDDM

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
- `setup-epos` → restore the EPOS ADAPT E1 / BTD 900c media-key setup on a fresh install
- `focus-or-launch` → jump to an existing app window or launch it on the target workspace
- `matlab-sway` → start MATLAB with the Sway / XWayland compatibility environment
- `notify-media` → show song/artist notifications for media transport keys
- `notify-layout` → watch keyboard layout changes and show `EN` / `IR` notifications
- `select-sway-host` → choose the active host-specific Sway file
- `wallpaper` → set wallpaper with fallback behavior
- `update-nvim` → refresh the Neovim AppImage

`mount-sd` accepts an explicit block device like `mount-sd /dev/mmcblk0p1`, but will also mount to `/mnt/sdcard` with the default helper path.

`setup-epos` checks for `playerctl`, detects the EPOS consumer-control device when the dongle is plugged in, and ensures the Sway media-key bindings are present without duplicating them. It also installs fallback bindings for `XF86AudioForward` and `XF86AudioRewind`, which some headsets expose instead of `Next` / `Prev`.

`focus-or-launch` is used by most `Mod+letter` launcher bindings. If the app is already open, it focuses the existing window and jumps to its workspace; otherwise it launches the app on the assigned workspace.

`matlab-sway` wraps your MATLAB install with the environment variables and launch flags needed for stable startup under Sway/XWayland.

`notify-media` is used by the Sway media-key bindings so play/pause/next/previous show a desktop notification with the current track for the active MPRIS player. When the player exposes album art through MPRIS, the notification also shows a thumbnail.

`notify-layout` runs in the background from Sway, shows a desktop notification when you switch keyboard layout, and works together with the Waybar language module so you can see `EN` / `IR` at a glance.

---

## Notifications

Notifications are handled by **SwayNotificationCenter** (`swaync`) instead of Mako or Dunst.

- `swaync` starts from Sway
- `Mod+Shift+n` toggles the notification center
- Waybar shows a notification icon module with left-click to open and right-click to toggle Do Not Disturb
- Waybar also shows the active keyboard layout as `EN` / `IR`

Config lives in:

- `config/swaync/config.json`
- `config/swaync/style.css`

If you previously had `dunst` installed, the Wayland layer tries to disable it so `org.freedesktop.Notifications` is owned by `swaync`.

---

## Key Bindings (Sway)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (kitty) |
| `Mod+d` | App launcher (rofi) |
| `Mod+w` | Focus or launch Firefox on workspace 2 |
| `Mod+e` | Focus or launch Nautilus on workspace 9 |
| `Mod+c` | Focus or launch VS Code on workspace 3 |
| `Mod+t` | Focus or launch Telegram on workspace 7 |
| `Mod+m` | Focus or launch Thunderbird on workspace 8 |
| `Mod+g` | Focus or launch GitHub Desktop on workspace 6 |
| `Mod+p` | Focus or launch Spotify on workspace 10 |
| `Mod+z` | Launch Zathura |
| `Mod+x` | Focus or launch Xournal++ on workspace 4 |
| `Mod+y` | Focus or launch MATLAB on workspace 5 |
| `Mod+Shift+t` | Open Catppuccin theme picker |
| `Mod+Shift+n` | Toggle notification center (`swaync`) |
| `Mod+Shift+e` | Power menu (rofi) |
| `Mod+Shift+x` | Lock screen (swaylock) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+Ctrl+s` | Stacking layout |
| `Mod+Ctrl+w` | Tabbed layout |
| `Mod+Ctrl+e` | Toggle split layout |
| `Mod+f` | Fullscreen |
| `Mod+r` | Resize mode |
| `Caps Lock` | Escape (remapped) |
| `Print` | Screenshot (grim) |
| `XF86AudioPlay / Pause / Next / Prev / Forward / Rewind` | Active media player transport with track notifications and album art when available |

Notes:

- `Mod+z` intentionally stays a plain Zathura launch.
- `Mod+Return` intentionally stays a plain Kitty launch on the current workspace.
