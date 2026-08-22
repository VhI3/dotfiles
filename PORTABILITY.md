# Portability Restore Checklist

Use this checklist when restoring the dotfiles onto a fresh minimal Debian system.

## 1. Base Access

- Log in with the target user.
- Make sure the user can use `sudo`.
- If needed, use:

```bash
su -
apt update
apt install -y sudo git curl wget ca-certificates
cd /tmp
git clone https://github.com/VhI3/dotfiles.git
cd dotfiles
bash layers/00-sudo.sh
```

## 2. Clone Dotfiles

```bash
git clone https://github.com/VhI3/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## 3. Run the Full Installer

Preferred non-interactive path:

```bash
./install.sh --fresh-minimal
```

Alternative:

- run `./install.sh`
- choose layers in order

Expected result:

- base packages installed
- Wayland/Sway stack installed
- development tools installed
- app stack installed
- dotfiles linked into `~/.config` and `~/.local/bin`

## 4. Create Local Machine Config Files

```bash
setup-local-configs
setup-paperless-tools
```

This should create or preserve:

- `~/.config/dotfiles/document-drives.env`
- `~/.config/dotfiles/document-shares.env`
- `~/.config/dotfiles/kulturzeit-downloader.env`
- `~/.config/dotfiles/media-shares.env`
- `~/.config/dotfiles/paperless-tools.local.conf`
- `~/.config/restic-backup.conf`
- `~/.config/restic/password`

## 5. Fill in Machine-Specific Values

Review and edit:

- `~/.config/dotfiles/document-drives.env`
  - mount points
  - disk UUIDs
- `~/.config/dotfiles/document-shares.env`
  - SMB host
  - `Documents_1` / `Documents_2` share names
  - laptop mount targets
- `~/.config/dotfiles/kulturzeit-downloader.env`
  - downloader project path
  - Jellyfin `Kulturzeit` target folder
  - `/mnt/tv_show` mount guard
- `~/.config/dotfiles/media-shares.env`
  - SMB host
  - share names
  - mount targets
- `~/.config/dotfiles/paperless-tools.local.conf`
  - scanner profile if needed
  - compose path if different
  - backup targets if different
- `~/.config/restic-backup.conf`
  - repository path
  - restore target
  - backup source list
- `~/.config/restic/password`
  - replace placeholder password

## 6. Re-Link After Editing

```bash
~/dotfiles/dots/link.sh
```

Why:

- refreshes symlinks
- refreshes `~/.local/bin` helpers
- reloads theme files
- re-runs host selection

## 7. Verify the Machine

Run:

```bash
post-install-check
```

This checks:

- core commands
- key linked configs
- local machine config files
- user systemd units and timers
- Paperless helper availability
- Sway helper availability

## 8. Optional Services

Only enable after local config is correct:

```bash
enable-ssd-hdd-mirror
enable-restic-documents-backup
enable-paperless-backup
```

Optional faster modes:

```bash
enable-ssd-hdd-mirror-fast
enable-paperless-backup-fast
```

Optional live sync:

```bash
enable-ssd-hdd-live-sync
```

## 9. Session Check

Confirm:

- `sway` starts
- `ghostty` starts
- `kitty` starts
- `rofi` opens
- `show-keybindings` works
- `changeTheme` works
- `waybar` loads
- `swaync` notifications work

## 10. Data Workflows

Confirm only if you use them on this machine:

- Paperless:
  - `check-paperless`
  - `backup-paperless-to-pcloud`
- Document mirror:
  - `run-ssd-hdd-mirror`
- Restic:
  - `restic-backup env`
  - `restic-backup snapshots`
- Media shares:
  - `mount-media-shares`
- Kulturzeit downloader:
  - restore the project source to `~/dev/kulturzeit-downloader`
  - `setup-kulturzeit-downloader`
  - `kulturzeit-downloader --dry-run`

## 11. Final Sanity

After the restore is complete, confirm:

- no machine-specific values were written back into tracked repo files
- active local settings live in `~/.config/dotfiles`
- sensitive credentials remain outside git
- the repo still only tracks example config files under `config/dotfiles`
