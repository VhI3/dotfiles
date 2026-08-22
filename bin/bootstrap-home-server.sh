#!/usr/bin/env bash
set -euo pipefail

APPLY=0
INSTALL_PACKAGES=1
INSTALL_DOCKER=1
CONFIGURE_SAMBA=1
CONFIGURE_SYSTEMD=1
START_APPS=1

SERVER_NAME="${SERVER_NAME:-home-server}"
SERVER_IP="${SERVER_IP:-192.168.1.10}"
TARGET_USER="${TARGET_USER:-${SUDO_USER:-${USER:-$(id -un)}}}"
TARGET_GROUP="${TARGET_GROUP:-$TARGET_USER}"

APPDATA_LABEL="${APPDATA_LABEL:-AppData}"
DOCUMENTS_1_LABEL="${DOCUMENTS_1_LABEL:-Documents_1}"
DOCUMENTS_2_LABEL="${DOCUMENTS_2_LABEL:-Documents_2}"

APPDATA_MOUNT="${APPDATA_MOUNT:-/AppData}"
DATA_MOUNT="${DATA_MOUNT:-/DATA}"
DOCUMENTS_1_MOUNT="${DOCUMENTS_1_MOUNT:-/mnt/Documents_1}"
DOCUMENTS_2_MOUNT="${DOCUMENTS_2_MOUNT:-/mnt/Documents_2}"

PAPERLESS_COMPOSE_DIR="${PAPERLESS_COMPOSE_DIR:-$APPDATA_MOUNT/compose/paperless}"
PAPERLESS_APPDATA_DIR="${PAPERLESS_APPDATA_DIR:-$APPDATA_MOUNT/paperless}"
PAPERLESS_MEDIA_DIR="${PAPERLESS_MEDIA_DIR:-$DOCUMENTS_1_MOUNT/20-Referenz/paperless-media}"
PAPERLESS_CONSUME_DIR="${PAPERLESS_CONSUME_DIR:-$DOCUMENTS_1_MOUNT/20-Referenz/paperless-consume}"
PAPERLESS_EXPORT_DIR="${PAPERLESS_EXPORT_DIR:-$DOCUMENTS_1_MOUNT/20-Referenz/paperless-export}"
PAPERLESS_EXPORT_CONTAINER_DIR="${PAPERLESS_EXPORT_CONTAINER_DIR:-/usr/src/paperless/export}"

MEDIA_APPS_CSV="${MEDIA_APPS_CSV:-homepage,jellyfin,navidrome,audiobookshelf}"

usage() {
    cat <<'EOF'
Usage:
  bootstrap-home-server [--apply] [options]

Purpose:
  Reconnect a fresh Ubuntu/Debian server install to the existing home-server
  disks and Docker Compose apps.

Default mode:
  Dry-run. Prints what would change, but does not write system files.

Options:
  --apply                 Actually write files, install packages, mount disks, and enable services.
  --no-packages           Do not install base packages.
  --no-docker             Do not install Docker packages.
  --no-samba              Do not configure Samba shares.
  --no-systemd            Do not write systemd services/timers.
  --no-start              Configure only; do not start/enable app services.
  --help, -h              Show this help.

Environment overrides:
  SERVER_IP=192.168.1.10
  TARGET_USER=your-user
  APPDATA_LABEL=AppData
  DOCUMENTS_1_LABEL=Documents_1
  DOCUMENTS_2_LABEL=Documents_2
  APPDATA_MOUNT=/AppData
  DATA_MOUNT=/DATA
  DOCUMENTS_1_MOUNT=/mnt/Documents_1
  DOCUMENTS_2_MOUNT=/mnt/Documents_2

Safety:
  This script does not format disks and does not delete existing app data.
EOF
}

log() {
    printf '==> %s\n' "$*"
}

warn() {
    printf 'WARN: %s\n' "$*" >&2
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

print_cmd() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
}

run() {
    if [ "$APPLY" -eq 1 ]; then
        print_cmd "$@"
        "$@"
    else
        printf '[dry-run]'
        printf ' %q' "$@"
        printf '\n'
    fi
}

run_sudo() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        run "$@"
    else
        run sudo "$@"
    fi
}

try_sudo() {
    if [ "$APPLY" -eq 0 ]; then
        printf '[dry-run]'
        if [ "${EUID:-$(id -u)}" -eq 0 ]; then
            printf ' %q' "$@"
        else
            printf ' %q' sudo "$@"
        fi
        printf '\n'
        return 0
    fi

    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        print_cmd "$@"
        "$@" || {
            warn "command failed but bootstrap will continue: $*"
            return 0
        }
    else
        print_cmd sudo "$@"
        sudo "$@" || {
            warn "command failed but bootstrap will continue: sudo $*"
            return 0
        }
    fi
}

write_root_file() {
    local path="$1"
    local mode="$2"
    local tmp
    tmp="$(mktemp)"
    cat >"$tmp"

    if [ "$APPLY" -eq 1 ]; then
        if [ "${EUID:-$(id -u)}" -eq 0 ]; then
            install -D -m "$mode" "$tmp" "$path"
        else
            sudo install -D -m "$mode" "$tmp" "$path"
        fi
        log "wrote $path"
    else
        log "dry-run: would write $path"
    fi

    rm -f "$tmp"
}

write_owned_file() {
    local path="$1"
    local mode="$2"
    local owner="$3"
    local group="$4"
    local tmp
    tmp="$(mktemp)"
    cat >"$tmp"

    if [ "$APPLY" -eq 1 ]; then
        if [ "${EUID:-$(id -u)}" -eq 0 ]; then
            install -D -m "$mode" -o "$owner" -g "$group" "$tmp" "$path"
        else
            sudo install -D -m "$mode" -o "$owner" -g "$group" "$tmp" "$path"
        fi
        log "wrote $path"
    else
        log "dry-run: would write $path"
    fi

    rm -f "$tmp"
}

append_root_line_if_missing() {
    local path="$1"
    local match_regex="$2"
    local line="$3"

    if [ -f "$path" ] && grep -Eq "$match_regex" "$path"; then
        log "already configured in $path: $line"
        return
    fi

    if [ "$APPLY" -eq 1 ]; then
        if [ "${EUID:-$(id -u)}" -eq 0 ]; then
            printf '%s\n' "$line" >>"$path"
        else
            printf '%s\n' "$line" | sudo tee -a "$path" >/dev/null
        fi
        log "added to $path: $line"
    else
        log "dry-run: would append to $path: $line"
    fi
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --apply)
                APPLY=1
                ;;
            --no-packages)
                INSTALL_PACKAGES=0
                ;;
            --no-docker)
                INSTALL_DOCKER=0
                ;;
            --no-samba)
                CONFIGURE_SAMBA=0
                ;;
            --no-systemd)
                CONFIGURE_SYSTEMD=0
                ;;
            --no-start)
                START_APPS=0
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                die "unknown option: $1"
                ;;
        esac
        shift
    done
}

require_apply_access() {
    if [ "$APPLY" -eq 0 ]; then
        return
    fi

    if [ "${EUID:-$(id -u)}" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
        die "sudo is required in --apply mode when not running as root"
    fi

    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        sudo -v
    fi
}

install_packages() {
    [ "$INSTALL_PACKAGES" -eq 1 ] || return 0

    log "installing base server packages"
    run_sudo apt-get update
    run_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        cifs-utils \
        curl \
        git \
        gnupg \
        openssl \
        rsync \
        samba \
        smbclient \
        wget

    [ "$INSTALL_DOCKER" -eq 1 ] || return 0

    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        log "Docker with compose plugin is already available"
    else
        log "installing Docker and Docker Compose plugin from distro packages"
        if [ "$APPLY" -eq 1 ]; then
            if ! run_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose-v2; then
                run_sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose-plugin
            fi
        else
            printf '[dry-run] sudo apt-get install -y docker.io docker-compose-v2\n'
            printf '[dry-run] if unavailable, try docker-compose-plugin\n'
        fi
    fi

    try_sudo systemctl enable --now docker

    if [ "$TARGET_USER" != "root" ]; then
        try_sudo usermod -aG docker "$TARGET_USER"
        warn "if Docker group membership was just added, log out and back in before using docker without sudo"
    fi
}

ensure_label_mount() {
    local label="$1"
    local mount_point="$2"
    local options="$3"
    local line
    line="LABEL=$label $mount_point ext4 $options 0 2"

    run_sudo mkdir -p "$mount_point"
    append_root_line_if_missing /etc/fstab "(^|[[:space:]])LABEL=${label}[[:space:]]|[[:space:]]${mount_point}[[:space:]]" "$line"

    if [ "$APPLY" -eq 1 ]; then
        if blkid -L "$label" >/dev/null 2>&1; then
            if findmnt -rno TARGET "$mount_point" >/dev/null 2>&1; then
                log "$mount_point is already mounted"
            else
                try_sudo mount "$mount_point"
            fi
        else
            warn "disk label not found: $label. Plug in the disk or adjust the label override."
        fi
    fi
}

configure_mounts() {
    log "configuring expected persistent mounts"
    ensure_label_mount "$APPDATA_LABEL" "$APPDATA_MOUNT" "defaults,nofail,x-systemd.device-timeout=30s,noatime"
    ensure_label_mount "$DOCUMENTS_1_LABEL" "$DOCUMENTS_1_MOUNT" "defaults,nofail,x-systemd.device-timeout=30s"
    ensure_label_mount "$DOCUMENTS_2_LABEL" "$DOCUMENTS_2_MOUNT" "defaults,nofail,x-systemd.device-timeout=30s"

    if [ "$APPLY" -eq 1 ]; then
        try_sudo mount -a
    else
        printf '[dry-run] sudo mount -a\n'
    fi

    if [ "$APPLY" -eq 1 ] && ! findmnt -rno TARGET "$DATA_MOUNT" >/dev/null 2>&1; then
        warn "$DATA_MOUNT is not mounted. Media apps can still be configured, but Jellyfin/Navidrome/Audiobookshelf may not see media until /DATA is mounted."
        warn "If the /DATA disk has no label, add its UUID to /etc/fstab manually."
    fi
}

ensure_paperless_dirs() {
    log "ensuring Paperless directories"

    if [ "$APPLY" -eq 1 ] && ! findmnt -rno TARGET "$APPDATA_MOUNT" >/dev/null 2>&1; then
        warn "$APPDATA_MOUNT is not mounted; skipping AppData directory creation to avoid fake local data"
        return
    fi

    if [ "$APPLY" -eq 1 ] && ! findmnt -rno TARGET "$DOCUMENTS_1_MOUNT" >/dev/null 2>&1; then
        warn "$DOCUMENTS_1_MOUNT is not mounted; skipping Paperless media/consume/export directory creation"
        return
    fi

    run_sudo mkdir -p "$PAPERLESS_COMPOSE_DIR"
    run_sudo mkdir -p "$PAPERLESS_APPDATA_DIR/data" "$PAPERLESS_APPDATA_DIR/db" "$PAPERLESS_APPDATA_DIR/redis"
    run_sudo mkdir -p "$PAPERLESS_MEDIA_DIR" "$PAPERLESS_CONSUME_DIR" "$PAPERLESS_EXPORT_DIR"
    run_sudo chown -R "$TARGET_USER:$TARGET_GROUP" "$PAPERLESS_COMPOSE_DIR" "$PAPERLESS_APPDATA_DIR"
    run_sudo chown -R "$TARGET_USER:$TARGET_GROUP" "$PAPERLESS_MEDIA_DIR" "$PAPERLESS_CONSUME_DIR" "$PAPERLESS_EXPORT_DIR"
}

ensure_paperless_env() {
    local env_file="$PAPERLESS_COMPOSE_DIR/.env"

    if [ "$APPLY" -eq 1 ] && ! findmnt -rno TARGET "$APPDATA_MOUNT" >/dev/null 2>&1; then
        warn "$APPDATA_MOUNT is not mounted; skipping Paperless .env creation to avoid fake local data"
        return 0
    fi

    if [ "$APPLY" -eq 1 ] && [ -f "$env_file" ]; then
        log "Paperless .env already exists; keeping it"
        return
    fi

    local db_password
    local secret_key
    if command -v openssl >/dev/null 2>&1; then
        db_password="$(openssl rand -base64 32)"
        secret_key="$(openssl rand -base64 64)"
    else
        db_password="CHANGE_ME_WITH_OPENSSL_RANDOM_VALUE"
        secret_key="CHANGE_ME_WITH_OPENSSL_RANDOM_VALUE"
    fi

    write_owned_file "$env_file" 0600 "$TARGET_USER" "$TARGET_GROUP" <<EOF
PAPERLESS_DB_PASSWORD=$db_password
PAPERLESS_SECRET_KEY=$secret_key
USERMAP_UID=$(id -u "$TARGET_USER" 2>/dev/null || id -u)
USERMAP_GID=$(id -g "$TARGET_USER" 2>/dev/null || id -g)
EOF
}

ensure_paperless_compose() {
    local compose_file="$PAPERLESS_COMPOSE_DIR/compose.yml"

    if [ "$APPLY" -eq 1 ] && ! findmnt -rno TARGET "$APPDATA_MOUNT" >/dev/null 2>&1; then
        warn "$APPDATA_MOUNT is not mounted; skipping Paperless compose creation to avoid fake local data"
        return 0
    fi

    if [ "$APPLY" -eq 1 ] && [ -f "$compose_file" ]; then
        log "Paperless compose.yml already exists; keeping it"
        if grep -q 'restart: unless-stopped' "$compose_file"; then
            log "switching Paperless restart policy to systemd-owned startup"
            run_sudo sed -i.bak-home-server-bootstrap 's/restart: unless-stopped/restart: "no"/g' "$compose_file"
        fi
        return
    fi

    write_owned_file "$compose_file" 0644 "$TARGET_USER" "$TARGET_GROUP" <<EOF
name: paperless

services:
  broker:
    image: docker.io/library/redis:8
    restart: "no"
    volumes:
      - $PAPERLESS_APPDATA_DIR/redis:/data

  db:
    image: docker.io/library/postgres:17
    restart: "no"
    volumes:
      - $PAPERLESS_APPDATA_DIR/db:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: \${PAPERLESS_DB_PASSWORD}

  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: "no"
    depends_on:
      - broker
      - db
      - gotenberg
      - tika
    ports:
      - "8000:8000"
    volumes:
      - $PAPERLESS_APPDATA_DIR/data:/usr/src/paperless/data
      - $PAPERLESS_MEDIA_DIR:/usr/src/paperless/media
      - $PAPERLESS_CONSUME_DIR:/usr/src/paperless/consume
      - $PAPERLESS_EXPORT_DIR:/usr/src/paperless/export
    environment:
      USERMAP_UID: \${USERMAP_UID}
      USERMAP_GID: \${USERMAP_GID}
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db
      PAPERLESS_DBNAME: paperless
      PAPERLESS_DBUSER: paperless
      PAPERLESS_DBPASS: \${PAPERLESS_DB_PASSWORD}
      PAPERLESS_SECRET_KEY: \${PAPERLESS_SECRET_KEY}
      PAPERLESS_TIME_ZONE: Europe/Berlin
      PAPERLESS_URL: http://$SERVER_IP:8000
      PAPERLESS_ALLOWED_HOSTS: $SERVER_IP,localhost,127.0.0.1,$SERVER_NAME
      PAPERLESS_CSRF_TRUSTED_ORIGINS: http://$SERVER_IP:8000,http://localhost:8000,http://$SERVER_NAME:8000
      PAPERLESS_OCR_LANGUAGE: deu+eng
      PAPERLESS_TIKA_ENABLED: 1
      PAPERLESS_TIKA_ENDPOINT: http://tika:9998
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT: http://gotenberg:3000

  gotenberg:
    image: docker.io/gotenberg/gotenberg:8
    restart: "no"
    command:
      - gotenberg
      - --chromium-disable-javascript=true
      - --chromium-allow-list=file:///tmp/.*

  tika:
    image: docker.io/apache/tika:latest
    restart: "no"
EOF
}

configure_samba() {
    [ "$CONFIGURE_SAMBA" -eq 1 ] || return 0

    log "configuring managed Samba shares"

    if [ "$APPLY" -eq 1 ] && findmnt -rno TARGET "$DATA_MOUNT" >/dev/null 2>&1; then
        run_sudo mkdir -p "$DATA_MOUNT/Filme" "$DATA_MOUNT/Series" "$DATA_MOUNT/Audiobooks" "$DATA_MOUNT/Music"
        run_sudo chown -R "$TARGET_USER:$TARGET_GROUP" "$DATA_MOUNT/Filme" "$DATA_MOUNT/Series" "$DATA_MOUNT/Audiobooks" "$DATA_MOUNT/Music"
    elif [ "$APPLY" -eq 1 ]; then
        warn "$DATA_MOUNT is not mounted; skipping media share directory creation"
    fi

    if [ "$APPLY" -eq 0 ]; then
        log "dry-run: would add/update managed share block in /etc/samba/smb.conf"
        return
    fi

    local tmp
    tmp="$(mktemp)"
    if [ -f /etc/samba/smb.conf ]; then
        awk '
            /^# BEGIN home-server dotfiles shares$/ { skip = 1; next }
            /^# END home-server dotfiles shares$/ { skip = 0; next }
            !skip { print }
        ' /etc/samba/smb.conf >"$tmp"
    fi

    cat >>"$tmp" <<EOF

# BEGIN home-server dotfiles shares
[Filme]
   path = $DATA_MOUNT/Filme
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Series]
   path = $DATA_MOUNT/Series
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Audiobooks]
   path = $DATA_MOUNT/Audiobooks
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Music]
   path = $DATA_MOUNT/Music
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Paperless-Consume]
   path = $PAPERLESS_CONSUME_DIR
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Documents_1]
   path = $DOCUMENTS_1_MOUNT
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = $TARGET_USER

[Documents_2]
   path = $DOCUMENTS_2_MOUNT
   browseable = yes
   read only = yes
   guest ok = no
   valid users = $TARGET_USER
# END home-server dotfiles shares
EOF

    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        install -m 0644 "$tmp" /etc/samba/smb.conf
    else
        sudo install -m 0644 "$tmp" /etc/samba/smb.conf
    fi
    rm -f "$tmp"

    try_sudo testparm -s
    try_sudo systemctl enable --now smbd
    try_sudo systemctl restart smbd

    local samba_users
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        samba_users="$(pdbedit -L 2>/dev/null || true)"
    else
        samba_users="$(sudo pdbedit -L 2>/dev/null || true)"
    fi

    if ! printf '%s\n' "$samba_users" | grep -q "^${TARGET_USER}:"; then
        warn "Samba user '$TARGET_USER' is not configured yet. Run: sudo smbpasswd -a $TARGET_USER"
    fi
}

configure_paperless_service() {
    [ "$CONFIGURE_SYSTEMD" -eq 1 ] || return 0

    write_root_file /etc/systemd/system/paperless.service 0644 <<EOF
[Unit]
Description=Paperless Docker Compose stack
Requires=docker.service
After=docker.service local-fs.target network-online.target
Wants=network-online.target
RequiresMountsFor=$APPDATA_MOUNT $DOCUMENTS_1_MOUNT
ConditionPathExists=$PAPERLESS_COMPOSE_DIR/compose.yml

[Service]
Type=oneshot
WorkingDirectory=$PAPERLESS_COMPOSE_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
}

configure_compose_apps_service() {
    [ "$CONFIGURE_SYSTEMD" -eq 1 ] || return 0

    write_root_file /usr/local/bin/start-home-server-compose-apps 0755 <<EOF
#!/usr/bin/env bash
set -euo pipefail

APP_ROOT="$APPDATA_MOUNT/compose"
DATA_MOUNT="$DATA_MOUNT"
APPS_CSV="\${HOME_SERVER_APPS:-$MEDIA_APPS_CSV}"

IFS=',' read -r -a APPS <<< "\$APPS_CSV"

log() {
  printf '==> %s\n' "\$*"
}

warn() {
  printf 'WARN: %s\n' "\$*" >&2
}

find_compose_file() {
  local app_dir="\$1"
  if [ -f "\$app_dir/compose.yml" ]; then
    printf '%s\n' "\$app_dir/compose.yml"
  elif [ -f "\$app_dir/docker-compose.yml" ]; then
    printf '%s\n' "\$app_dir/docker-compose.yml"
  fi
}

for app in "\${APPS[@]}"; do
  app="\${app//[[:space:]]/}"
  [ -n "\$app" ] || continue

  app_dir="\$APP_ROOT/\$app"
  compose_file="\$(find_compose_file "\$app_dir" || true)"

  if [ -z "\$compose_file" ]; then
    warn "missing compose file for \$app under \$app_dir; skipping"
    continue
  fi

  case "\$app" in
    jellyfin|navidrome|audiobookshelf)
      if ! mountpoint -q "\$DATA_MOUNT"; then
        warn "\$DATA_MOUNT is not mounted; skipping \$app"
        continue
      fi
      ;;
  esac

  log "starting \$app"
  docker compose --project-directory "\$app_dir" -f "\$compose_file" up -d
done
EOF

    write_root_file /etc/systemd/system/home-server-compose-apps.service 0644 <<EOF
[Unit]
Description=Start home-server Docker Compose apps
Requires=docker.service
After=docker.service local-fs.target network-online.target
Wants=network-online.target
RequiresMountsFor=$APPDATA_MOUNT
ConditionPathExists=$APPDATA_MOUNT/compose

[Service]
Type=oneshot
ExecStart=/usr/local/bin/start-home-server-compose-apps
RemainAfterExit=yes
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
}

configure_mirror_service() {
    [ "$CONFIGURE_SYSTEMD" -eq 1 ] || return 0

    write_root_file /usr/local/bin/mirror-documents-drives 0755 <<EOF
#!/usr/bin/env bash
set -euo pipefail

SRC="$DOCUMENTS_1_MOUNT/"
DST="$DOCUMENTS_2_MOUNT/"

if ! mountpoint -q "$DOCUMENTS_1_MOUNT"; then
  echo "Documents_1 is not mounted; skipping mirror."
  exit 0
fi

if ! mountpoint -q "$DOCUMENTS_2_MOUNT"; then
  echo "Documents_2 is not mounted; skipping mirror."
  exit 0
fi

echo "Mirroring \$SRC -> \$DST"
rsync -aHAX --delete --info=stats2,progress2 "\$SRC" "\$DST"
echo "Mirror finished."
EOF

    write_root_file /etc/systemd/system/mirror-documents-drives.service 0644 <<EOF
[Unit]
Description=Mirror Documents_1 SSD to Documents_2 HDD
RequiresMountsFor=$DOCUMENTS_1_MOUNT $DOCUMENTS_2_MOUNT

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mirror-documents-drives
EOF

    write_root_file /etc/systemd/system/mirror-documents-drives.timer 0644 <<'EOF'
[Unit]
Description=Run Documents SSD->HDD mirror hourly

[Timer]
OnBootSec=10min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF
}

configure_paperless_backup_service() {
    [ "$CONFIGURE_SYSTEMD" -eq 1 ] || return 0

    write_root_file /usr/local/bin/export-paperless-documents 0755 <<EOF
#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="$PAPERLESS_COMPOSE_DIR"
APPDATA_MOUNT="$APPDATA_MOUNT"
DOCUMENTS_1_MOUNT="$DOCUMENTS_1_MOUNT"
EXPORT_DIR="$PAPERLESS_EXPORT_DIR"
CONTAINER_EXPORT_DIR="$PAPERLESS_EXPORT_CONTAINER_DIR"

log() {
  printf '==> %s\n' "\$*"
}

skip() {
  printf 'paperless export skipped: %s\n' "\$*"
  exit 0
}

die() {
  printf 'paperless export failed: %s\n' "\$*" >&2
  exit 1
}

mountpoint -q "\$APPDATA_MOUNT" || skip "\$APPDATA_MOUNT is not mounted"
mountpoint -q "\$DOCUMENTS_1_MOUNT" || skip "\$DOCUMENTS_1_MOUNT is not mounted"
[ -f "\$COMPOSE_DIR/compose.yml" ] || die "missing compose file: \$COMPOSE_DIR/compose.yml"

mkdir -p "\$EXPORT_DIR"

log "exporting Paperless documents and metadata"
log "compose: \$COMPOSE_DIR"
log "export:  \$EXPORT_DIR"

cd "\$COMPOSE_DIR"
docker compose ps
docker compose exec -T webserver document_exporter -d -p "\$CONTAINER_EXPORT_DIR"

if [ -f "\$EXPORT_DIR/manifest.json" ]; then
  log "manifest updated"
  ls -lh "\$EXPORT_DIR/manifest.json"
else
  die "manifest.json was not created in \$EXPORT_DIR"
fi

log "Paperless export finished"
EOF

    write_root_file /etc/systemd/system/paperless-export-backup.service 0644 <<EOF
[Unit]
Description=Export Paperless documents and metadata
Requires=docker.service
After=docker.service paperless.service
Wants=paperless.service
RequiresMountsFor=$APPDATA_MOUNT $DOCUMENTS_1_MOUNT
ConditionPathExists=$PAPERLESS_COMPOSE_DIR/compose.yml

[Service]
Type=oneshot
ExecStart=/usr/local/bin/export-paperless-documents
ExecStartPost=-/usr/bin/systemctl start mirror-documents-drives.service
TimeoutStartSec=0
EOF

    write_root_file /etc/systemd/system/paperless-export-backup.timer 0644 <<'EOF'
[Unit]
Description=Run Paperless export backup hourly

[Timer]
OnBootSec=20min
OnUnitActiveSec=1h
Persistent=true
RandomizedDelaySec=5m
Unit=paperless-export-backup.service

[Install]
WantedBy=timers.target
EOF
}

start_services() {
    [ "$CONFIGURE_SYSTEMD" -eq 1 ] || return 0

    log "reloading systemd"
    try_sudo systemctl daemon-reload

    [ "$START_APPS" -eq 1 ] || return 0

    log "enabling server services"
    try_sudo systemctl enable --now home-server-compose-apps.service
    try_sudo systemctl enable --now paperless.service
    try_sudo systemctl enable --now mirror-documents-drives.timer
    try_sudo systemctl enable --now paperless-export-backup.timer
    try_sudo systemctl start mirror-documents-drives.service
}

show_summary() {
    cat <<EOF

==> Next checks
systemctl status home-server-compose-apps.service --no-pager
systemctl status paperless.service --no-pager
systemctl status paperless-export-backup.timer --no-pager
systemctl status mirror-documents-drives.timer --no-pager
docker compose ls
curl -I http://localhost:8000
smbclient -L //localhost -U $TARGET_USER

If Samba login fails, create/update the Samba password:
sudo smbpasswd -a $TARGET_USER

If Docker was installed today, log out and back in before using docker without sudo.
EOF
}

main() {
    parse_args "$@"

    log "home server bootstrap"
    log "mode: $([ "$APPLY" -eq 1 ] && printf apply || printf dry-run)"
    log "server: $SERVER_NAME ($SERVER_IP)"
    log "target user: $TARGET_USER"

    require_apply_access
    install_packages
    configure_mounts
    ensure_paperless_dirs
    ensure_paperless_env
    ensure_paperless_compose
    configure_samba
    configure_paperless_service
    configure_compose_apps_service
    configure_mirror_service
    configure_paperless_backup_service
    start_services
    show_summary
}

main "$@"
