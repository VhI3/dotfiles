# paperless-tools

Small local helpers for a Debian document workflow built around:

`NAPS2 -> Scan-Inbox -> Paperless-ngx -> OCR / metadata / search -> backup`

The toolkit is designed to survive a laptop replacement:

- tracked defaults stay portable and user-relative
- machine-specific overrides live in `~/.config/dotfiles/paperless-tools.local.conf`
- the scripts avoid silently creating fake backup folders when pCloud or the external SSD is not ready

## Workflow

1. Scan documents with `NAPS2` into:
   - `PAPERLESS_CONSUME_DIR`
   - `$HOME/Documents/Scan-Inbox` by default
   - `/mnt/paperless-consume` for the server-based client setup
2. Paperless-ngx watches the consume folder and imports new scans.
3. Paperless performs OCR, metadata extraction, and full-text search.
4. `backup-paperless-to-pcloud.sh` exports Paperless documents and metadata.
5. The export is synced to:
   - pCloud backup target
   - external SSD backup target

The live Paperless data stays in Docker volumes/bind mounts. Only exported data
is synced to pCloud or the external SSD.

## Files

- `paperless-tools.conf`
- `paperless-tools.local.conf.example`
- `paperless-tools.lib.sh`
- `scan-to-paperless.sh`
- `scan-glass-to-paperless.sh`
- `list-naps2-profiles.sh`
- `backup-paperless-to-pcloud.sh`
- `restore-paperless-from-export.sh`
- `check-paperless.sh`

## Portability Model

Use this split:

- `paperless-tools.conf`
  - tracked in git
  - contains portable defaults based on `$HOME` and `$USER`
- `~/.config/dotfiles/paperless-tools.local.conf`
  - not tracked in git
  - only for machine-specific overrides

Setup on a new Debian laptop:

```bash
cd ~/dotfiles/projects/paperless-tools
setup-paperless-tools
```

Then edit only what differs on that laptop, for example:

- custom Paperless compose location
- custom Paperless consume directory
- server-only Paperless URL and consume SMB mount
- custom NAPS2 profile name
- backup targets if your document SSD mount changes

Example laptop client setup for a Paperless server:

```bash
PAPERLESS_SERVER_ONLY=1
PAPERLESS_URL="http://192.168.1.10:8000"
PAPERLESS_CONSUME_DIR="/mnt/paperless-consume"
PAPERLESS_CONSUME_MOUNT="/mnt/paperless-consume"
PAPERLESS_CONSUME_MUST_BE_MOUNTED=1
PAPERLESS_CONSUME_SMB_SHARE="//192.168.1.10/Paperless-Consume"
PAPERLESS_SMB_CREDENTIALS_FILE="$HOME/.smb/home-server"
PAPERLESS_OCR_LANGUAGE="deu+eng"
```

In server-only mode, `check-paperless` checks the server URL and skips local
Docker Compose checks.

## Usage

Scan a document:

```bash
./scan-to-paperless.sh
```

This is the normal smart mode. It tries the duplex feeder first, then falls back
to a manual glass scan if the feeder scan fails or produces no PDF.
If `PAPERLESS_CONSUME_MUST_BE_MOUNTED=1`, the script refuses to scan until the
server consume share is mounted. This prevents accidental scans into a fake
local `/mnt` folder.

Mount the server consume share:

```bash
mount-paperless-consume
```

Force duplex feeder only:

```bash
./scan-to-paperless.sh --mode duplex
```

Scan a thick or two-sided document from the scanner glass:

```bash
./scan-to-paperless.sh --mode glass
```

This scans 2 pages into one color PDF by default and waits for Enter before each page.
For more pages:

```bash
./scan-to-paperless.sh --mode glass --pages 4
```

Use the physical order you want in the final PDF: front, back, next front, next
back. Paperless will import the finished PDF from the consume folder.

For smaller grayscale PDFs:

```bash
./scan-to-paperless.sh --mode glass --bitdepth gray
```

`./scan-glass-to-paperless.sh` still exists as a compatibility shortcut for
`./scan-to-paperless.sh --mode glass`.

Scans are written to a temporary file first, then moved into the consume folder
only after success. This keeps Paperless from importing a half-failed scan.

If scanning fails with this NAPS2/PdfSharpCore error:

```text
An item with the same key has already been added. Key: universalis adf std cond
```

the dotfiles include a fontconfig workaround that hides the duplicate-prone
Debian `Universalis ADF` font family for the current user. Relink and refresh
the font cache:

```bash
cd ~/dotfiles
./dots/link.sh
fc-cache -f
```

List NAPS2 profiles and scanner devices:

```bash
./list-naps2-profiles.sh
```

Check Paperless health:

```bash
./check-paperless.sh
```

Export and back up Paperless data:

```bash
./backup-paperless-to-pcloud.sh
```

Dry-run a restore from the latest available export:

```bash
./restore-paperless-from-export.sh
```

Restore into a fresh/empty Paperless instance:

```bash
./restore-paperless-from-export.sh --source /media/$USER/Documents_1/20-Referenz/paperless-export --apply
```

## Notes

- OCR languages are configured in Paperless as `deu+eng`.
- `PAPERLESS_CONSUME_DIR` is the real Paperless intake path used by the helpers.
- `PAPERLESS_CONSUME_MUST_BE_MOUNTED=1` protects server/client setups from scanning into an unmounted path.
- `SCAN_INBOX` is kept as a backward-compatible alias for older configs.
- The export command writes to the compose-side `export/` folder.
- The backup script then syncs that export to pCloud and the external SSD.
- The restore script is dry-run by default and refuses to import into a non-empty archive unless `--allow-existing-documents` is passed.
- If pCloud or the document SSD is not ready, the backup script skips that target instead of creating a misleading local folder tree.
- The scripts detect common compose filenames:
  - `docker-compose.yml`
  - `docker-compose.yaml`
  - `compose.yml`
  - `compose.yaml`
