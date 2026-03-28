# dotfiles

A minimalist, keyboard-driven Linux setup built on **Debian (server base)**. No desktop environment — just the tools that matter. Everything is intentional: dark themes, Vim keybindings, and a clean Wayland compositor stack.

---

## Philosophy

- Start from Debian minimal (server ISO) — no GNOME, no KDE, no bloat
- Build up only what is needed, layer by layer
- Consistent dark theme (Dracula) across every tool
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
| [Mako](https://github.com/emersion/mako) | Notification daemon |
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
| Mutt | Terminal email client |
| Lazygit | Terminal Git UI |

---

## Structure

```
dotfiles/
├── install.sh          ← interactive installer
├── layers/             ← install scripts, run in order
│   ├── 00-sudo.sh      ← add user to sudoers (run as root first)
│   ├── 01-base.sh      ← apt essentials, Python, Node (nvm), Rust
│   ├── 02-cli.sh       ← Neovim, fzf, ranger, eza, lazygit, bat, pass, vim
│   ├── 03-wayland.sh   ← sway stack, kitty, rofi, mako, grim, swaylock
│   ├── 04-fonts.sh     ← JetBrainsMono & SpaceMono Nerd Fonts
│   ├── 05-dev.sh       ← gcc, cmake, ninja, clangd, gdb, rust-analyzer, lua
│   ├── 06-apps.sh      ← firefox, librewolf, spotify, thunderbird, vscodium
│   ├── 07-grub.sh      ← GRUB bootloader theme
│   └── 08-octave.sh    ← GNU Octave with symbolic & statistics packages
├── dots/
│   └── link.sh         ← symlinks everything to the right place
├── config/             ← ~/.config/* (sway, waybar, nvim, rofi, ...)
│   ├── kitty/          ← minimal Kitty config
│   └── sway/hosts/     ← per-machine Sway settings
├── home/               ← ~/.*  (bashrc, bash_aliases, vimrc)
├── bin/                ← ~/.local/bin/ (toggle_audio, update-nvim, wallpaper, ...)
└── assets/
    ├── wallpapers/     ← Dracula wallpapers
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

Linking also runs the Sway host selector automatically. If the current hostname matches a file in `config/sway/hosts/`, it becomes the active per-machine Sway config.

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

- `laptop`

To add another machine:

```bash
cp config/sway/hosts/laptop.conf config/sway/hosts/workstation.conf
~/.local/bin/select-sway-host workstation
```

The generated file `config/sway/host.local.conf` is local state and is intentionally not tracked by git.

---

## Theme

**Dracula** throughout — Kitty, Neovim, Vim, Rofi, Mako, Lazygit, Mutt, FZF, Ranger.
Font: **JetBrainsMono Nerd Font** (terminals, status bar, editors).

---

## Key Bindings (Sway)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (kitty) |
| `Mod+d` | App launcher (rofi) |
| `Mod+Shift+e` | Power menu (rofi) |
| `Mod+Shift+x` | Lock screen (swaylock) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+f` | Fullscreen |
| `Mod+r` | Resize mode |
| `Caps Lock` | Escape (remapped) |
| `Print` | Screenshot (grim) |
