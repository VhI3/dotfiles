# Cheat Sheet

Practical command reference for this Debian dotfiles setup. Start at the top for daily work, then move down to storage, backup, Paperless, and recovery tasks.

## Quick Start

Most-used commands:

```bash
aaa
show-keybindings
changeTheme mocha
changeTheme latte
post-install-check
```

`aaa` updates the system and runs your routine maintenance helper.
`show-keybindings` opens your Sway shortcut reference.
`changeTheme ...` switches the desktop theme across your themed apps.
`post-install-check` verifies that a freshly restored machine is ready.

Useful first checks:

```bash
findmnt /media/$USER/Documents_1 /media/$USER/Documents_2
systemctl --user status ssd-hdd-mirror.timer
systemctl --user status restic-documents-backup.timer
restic-backup snapshots
```

These commands quickly confirm that the document drives are mounted and the backup timers are healthy.

## Daily Shell

Update packages and daily maintenance:

```bash
aaa
```

Runs your usual package refresh and update flow.

Open editor, list files, and inspect directories:

```bash
e
ll
la
lt
tree1
tree2
du1
du2
```

These are your fast everyday navigation and file-inspection helpers.

Safer file operations:

```bash
mvx oldname newname
cpfast /source/path /dest/path
trash-put file
```

`mvx` moves with safer defaults, `cpfast` copies large data with progress, and `trash-put` avoids permanent deletion.

Navigation helpers:

```bash
.. 
...
....
.....
cdd
cdl
cdp
```

Shortcuts for moving up directories and jumping to your common working locations.

Search and inspection:

```bash
ff pattern
rg "text"
fd name
bat file
glow README.md
ncdu
duf
btop
```

Use these to find files, search inside them, preview content, and inspect disk or system usage.

Git shortcuts:

```bash
gs
ga .
gc "message"
gp
gpl
gd
gco branch-name
lg
```

These wrap the most common Git actions: status, add, commit, push, diff, checkout, and lazygit.

Archives:

```bash
extract archive.zip
mkzip folder
```

Quick helpers to unpack or create archives without remembering long flags.

Mail helper:

```bash
mutt-mail -s "Subject" recipient@example.com /path/to/file.pdf
```

Sends a file by email directly from the terminal.

## Desktop And Theme

Show the Sway keybinding helper:

```bash
show-keybindings
```

Useful when you forget a launcher, workspace, or window-management shortcut.

Change the desktop theme:

```bash
changeTheme latte
changeTheme frappe
changeTheme macchiato
changeTheme mocha
```

Applies one theme choice across your desktop tooling and themed applications.

Available flavors:

```bash
theme-list
```

Lists the theme names that your `changeTheme` script accepts.

Current theme:

```bash
theme-current
```

Shows the currently active theme flavor.

Apply local machine-specific config files after linking:

```bash
setup-local-configs
```

Recreates local config files that are intentionally kept outside Git for portability.

## Apps And Devices

Bluetooth helpers:

```bash
bluetoothctl
pair-keychron-bt
```

Use these to inspect Bluetooth devices and re-pair the Keychron keyboard quickly.

Audio and media:

```bash
playerctl play-pause
playerctl next
playerctl previous
```

Manual media controls for testing or for use outside your keyboard shortcuts.

Keyboard/media notifications are handled through the Sway/Waybar notification scripts already wired into the dotfiles.

## Files, PDFs, And Library Work

Collect likely books from a folder:

```bash
collect-books
collect-books --source ~/Downloads
collect-books --source ~/Downloads --target zwischenlager
collect-books --source ~/Downloads --target zwischenlager --min-pages 120
collect-books --help
```

Scans a folder for likely book PDFs and gathers them into one place for later review.

Normalize filenames to portable POSIX style:

```bash
normalize-names ~/Downloads
normalize-names --folders ~/Downloads
normalize-names --apply ~/Downloads
normalize-names --help
```

Renames files into cleaner, shell-friendly names with portable Linux-safe formatting.

Rename PDFs from detected title metadata:

```bash
rename-pdf-from-title ~/Downloads/file.pdf
rename-pdf-from-title --apply ~/Downloads
```

Uses PDF metadata or extracted title hints to rename files more meaningfully.

Sort PDFs into books, theses, papers, and others:

```bash
sort-pdfs --source ~/Downloads/pdfs --dest ~/Downloads/sorted
sort-pdfs --source ~/Downloads/pdfs --dest ~/Downloads/sorted --apply
sort-pdfs --help
```

Classifies PDFs into document-type folders and helps reduce manual sorting work.

Sort mixed folders more broadly:

```bash
sort-library --source ~/Downloads/tmpp --dest ~/Downloads/tmpp --apply
sort-library --help
```

Sorts larger mixed collections, not only PDFs, into cleaner groups.

Clean LaTeX build artifacts recursively:

```bash
latex-clean .
latex-clean ~/Documents/project
latex-clean --apply ~/Documents/project
latex-clean --help
```

Removes `.aux`, `.log`, `.out`, and similar generated files while keeping your actual documents.

Ranger is configured as the preferred terminal file manager for quick PDF review workflows.

It is the fastest option here for browsing, previewing, and cleaning large PDF folders.

## Storage And Mounts

Show removable USB drives, SD cards, and external disks:

```bash
blk
```

Shows the storage devices you usually care about, without too much internal-disk noise.

Mount a removable partition under `/media/$USER/...`:

```bash
mnt /dev/sda1
```

Mounts a partition into your normal user media directory.

Mount and jump into it directly:

```bash
mntcd /dev/sda1
```

Mounts the device and immediately opens that location in the shell.

List mounted storage clearly:

```bash
findmnt
lsblk -f
```

Useful for checking what is mounted, where it is mounted, and which filesystem it uses.

Mount SMB/CIFS network shares:

```bash
mntsmb "//192.168.1.10/Filme" filme
mntsmb "//192.168.1.10/Series" tv_show
mntsmb "//192.168.1.10/Audiobooks" audiobooks
mntsmb "//192.168.1.10/Music" music
mntsmb "//192.168.1.10/Paperless-Consume" paperless-consume
```

Mounts network shares from your server into predictable local mount points.

Mount server document SSD/HDD shares:

```bash
mount-document-shares
```

Mounts `Documents_1` to `/mnt/documents_1` for work and `Documents_2` to
`/mnt/documents_2` read-only for checking the HDD mirror.

Mount only the working SSD:

```bash
mount-document-shares --master-only
```

Mount configured media shares:

```bash
mount-media-shares
```

Runs your saved network-share mounting workflow, including the Paperless consume folder when `PAPERLESS_CONSUME_SHARE` is configured.

Download Kulturzeit into Jellyfin:

```bash
kulturzeit-downloader
```

Downloads to `/mnt/tv_show/Kulturzeit`. If `/mnt/tv_show` is not mounted, the
dotfiles launcher tries `mount-media-shares` first.

Test without downloading:

```bash
kulturzeit-downloader --dry-run
```

Fresh Debian setup:

```bash
setup-kulturzeit-downloader
```

Unmount configured media shares:

```bash
umount-media-shares
```

Cleanly disconnects the configured network-share mounts.

Check share mounts:

```bash
findmnt /mnt/filme /mnt/tv_show /mnt/audiobooks /mnt/music
```

Confirms whether the media shares are currently mounted.

## Document Drives And Backup

Your current external document setup:

```text
Source SSD: /media/$USER/Documents_1
Mirror HDD: /media/$USER/Documents_2
```

This is your main document-storage pair: one working drive and one mirror drive.

Manual mirror run:

```bash
ssd-hdd-mirror
```

Performs a one-time mirror sync from the SSD to the HDD.

Preview mirror changes without writing:

```bash
ssd-hdd-mirror --dry-run
```

Shows what would change before you run the real sync.

Enable scheduled mirror mode:

```bash
enable-ssd-hdd-mirror
```

Turns on the timer-based mirror service.

Disable scheduled mirror mode:

```bash
disable-ssd-hdd-mirror
```

Turns off the timer-based mirror service.

Check timer and recent logs:

```bash
systemctl --user status ssd-hdd-mirror.timer
journalctl --user -u ssd-hdd-mirror.service -n 50 --no-pager
```

Use this first if the mirror did not run when you expected.

Optional near-live sync watcher:

```bash
enable-ssd-hdd-live-sync
disable-ssd-hdd-live-sync
systemctl --user status ssd-hdd-live-sync.service
```

This mode watches for changes and propagates them faster, but it is more aggressive than timer-based sync.

Restic snapshots for versioned backup:

```bash
restic-backup init
restic-backup
restic-backup snapshots
restic-backup forget --prune
```

Use restic when you want versioned recovery, not just a mirrored copy.

Enable the restic timer:

```bash
enable-restic-documents-backup
```

Turns on scheduled snapshot backups.

Check restic timer and logs:

```bash
systemctl --user status restic-documents-backup.timer
journalctl --user -u restic-documents-backup.service -n 50 --no-pager
```

This is the quickest place to check whether snapshots are actually succeeding.

If the external drives are missing, the service now skips politely and logs `backup skipped: ...` instead of showing a hard failure.

Recommended model:

```text
Mirror HDD: fast recovery copy
Restic: versioned snapshots against mistakes/corruption
Live sync: optional, only if you truly need near-immediate propagation
```

This gives you both quick recovery and safer historical rollback.

One important trust check:

```bash
restic-backup restore
```

Run one real restore test into a temporary folder later. A backup is only fully trusted after one successful restore.

## Paperless Workflow

Workflow:

```text
NAPS2 -> Scan-Inbox -> Paperless-ngx -> OCR/search/metadata -> export backup
```

This is the intended document-ingestion path from scanning to searchable archive and backup.

Mount server Paperless consume folder:

```bash
mount-paperless-consume
```

Use this on the laptop before scanning when Paperless runs on `home-server`.

Scan directly into the inbox:

```bash
scan-to-paperless
```

Creates a timestamped scan PDF inside the Paperless intake folder. This is the normal smart mode: it tries the duplex feeder first, then falls back to the scanner glass if the feeder scan fails.
If the consume folder is configured under `/mnt` and is not mounted, the script stops safely instead of scanning into a fake local folder.

Force duplex feeder only:

```bash
scan-to-paperless --mode duplex
```

Use this when you know the pages are in the ADF and do not want glass fallback.

Force flatbed/glass only:

```bash
scan-to-paperless --mode glass
```

Scans 2 pages by default, waits for Enter before each page, and uses color by default.

Scan more glass pages into one PDF:

```bash
scan-to-paperless --mode glass --pages 4
```

Use page order `front, back, next front, next back` so the final PDF is already correct.

Use grayscale for smaller files:

```bash
scan-to-paperless --mode glass --bitdepth gray
```

If NAPS2 crashes with a `universalis adf std cond` duplicate-font error:

```bash
fc-cache -f
fc-list : family file | rg -i 'universalis adf|universalis'
```

The second command should print nothing after the dotfiles font workaround is linked.

List NAPS2 profiles:

```bash
list-naps2-profiles
```

Helps you identify the exact scanner profile name if you need to customize scanning later.

Check whether Paperless is healthy:

```bash
check-paperless
```

Verifies Docker services on local setups. In server-only/client mode, it checks the server URL and skips local Docker Compose checks.

Export Paperless and sync backup target:

```bash
backup-paperless-to-pcloud
```

Exports Paperless data and mirrors the export to your backup destination.
For the current server-based Paperless setup, prefer the server timer below.

Check server-side Paperless backup:

```bash
ssh your-user@192.168.1.10
systemctl status paperless-export-backup.timer --no-pager
systemctl status paperless-export-backup.service --no-pager
journalctl -u paperless-export-backup.service -n 80 --no-pager
ls -lh /mnt/Documents_1/20-Referenz/paperless-export/manifest.json
```

Manually run the server export and then mirror:

```bash
sudo systemctl start paperless-export-backup.service
```

This exports Paperless metadata/documents into `paperless-export` on
`Documents_1`; the service then triggers the `Documents_1 -> Documents_2`
mirror.

Dry-run a Paperless restore:

```bash
restore-paperless-from-export
```

Restore into a fresh/empty Paperless instance:

```bash
restore-paperless-from-export --source /media/$USER/Documents_1/20-Referenz/paperless-export --apply
```

The restore helper refuses to import into a non-empty archive unless `--allow-existing-documents` is passed.

Paperless local settings live outside the repo here:

```text
~/.config/dotfiles/paperless-tools.local.conf
```

That keeps machine-specific paths and credentials out of Git.

This keeps the dotfiles portable across machines.

## Local AI And LLM Helpers

Ollama:

```bash
ollama ps
ollama list
ollama run gemma4:e4b
```

Basic commands for checking the Ollama daemon, installed models, and launching one interactively.

File-agent helper:

```bash
file-agent plan /path/to/folder
file-agent organize /path/to/folder
```

Uses your local LLM tooling to inspect or propose file-management actions.

llama.cpp / local completion-related checks:

```bash
which llama-server
llama-server --version
```

Use these when debugging local completion tooling in VS Code or terminal workflows.

## Restore And Portability

Read the restore checklist:

```bash
glow PORTABILITY.md
```

This is the high-level restore guide for rebuilding the system on a fresh Debian install.

Bootstrap the home-server after a fresh server reinstall:

```bash
bootstrap-home-server
bootstrap-home-server --apply
```

The first command is a dry-run. The `--apply` command installs server basics,
reconnects `/AppData`, `Documents_1`, and `Documents_2`, configures Samba and
systemd, starts the Docker Compose apps, and enables the hourly document mirror.

Read the detailed server bootstrap guide:

```bash
glow docs/HOME-SERVER-SERVER-BOOTSTRAP.md
```

Run the machine verification after linking dotfiles:

```bash
post-install-check
```

Confirms that the restored machine has the expected commands, paths, and services.

Link dotfiles:

```bash
./dots/link.sh
```

Creates the symlinks from this repository into the right config locations.

Then apply portable local config files:

```bash
setup-local-configs
```

Rebuilds local-only settings that should exist on the machine but not be tracked in Git.

Portable local settings are intentionally stored outside the repo under:

```text
~/.config/dotfiles/
```

That design is what makes the setup portable across different laptops.

## If Something Breaks

Check user services:

```bash
systemctl --user status service-name
journalctl --user -u service-name -n 100 --no-pager
```

Use this for systemd user services that fail silently or behave inconsistently.

Reload user systemd:

```bash
systemctl --user daemon-reload
```

Run this after changing user service files or timers.

Check mounts:

```bash
findmnt
lsblk -f
```

Useful when drives or network shares are missing or mounted in the wrong place.

Check backup state:

```bash
systemctl --user status ssd-hdd-mirror.timer
systemctl --user status restic-documents-backup.timer
restic-backup snapshots
```

These are the core commands to verify that your document-protection setup is still working.

Check Paperless:

```bash
check-paperless
```

Use this when Paperless does not open or stops ingesting documents.

Check the machine after a fresh restore:

```bash
post-install-check
```

Run this at the end of a restore or after major setup work.

Check Neovim health:

```bash
nvim-repair doctor
```

Repair Neovim Lazy plugin-cache corruption:

```bash
nvim-repair lazy-cache neotest nvim-nio
nvim-repair update neotest nvim-nio
nvim-repair lspconfig-cache
```

Use this if Neovim reports an LSP file like `pyright.lua` is `not a table`, or
Lazy update fails with broken Git refs such as `cannot lock ref`. The old
`repair-nvim-lazy-cache` and `repair-nvim-lspconfig-cache` commands still work
as compatibility shortcuts.
