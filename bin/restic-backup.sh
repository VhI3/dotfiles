#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
CONFIG_FILE="${RESTIC_BACKUP_CONFIG:-$HOME/.config/restic-backup.conf}"

usage() {
    cat <<'EOF'
Usage: restic-backup <command>

Simple restic wrapper for local SSD -> HDD backups.

Commands:
  init        Initialize the repository
  backup      Create a new backup snapshot
  snapshots   List snapshots
  ls          List files in the latest snapshot
  check       Verify repository integrity
  unlock      Remove stale repository locks
  forget      Apply retention policy and prune old snapshots
  restore     Restore the latest snapshot to RESTORE_TARGET
  env         Show resolved configuration
  help        Show this help

Configuration file:
  ~/.config/restic-backup.conf

Required variables:
  RESTIC_REPOSITORY=/path/to/hdd/restic-repo
  RESTIC_PASSWORD_FILE=/path/to/password-file

Optional variables:
  BACKUP_SOURCES="$HOME/Documents $HOME/dotfiles"
  RESTIC_TAGS="laptop local"
  KEEP_DAILY=7
  KEEP_WEEKLY=4
  KEEP_MONTHLY=6
  KEEP_YEARLY=2
  RESTORE_TARGET="$HOME/restore-restic"

Examples:
  restic-backup init
  restic-backup backup
  restic-backup snapshots
  restic-backup forget
EOF
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "$SCRIPT_NAME: required command missing: $1" >&2
        exit 1
    }
}

need_cmd restic

if [ ! -f "$CONFIG_FILE" ]; then
    cat >&2 <<EOF
$SCRIPT_NAME: config file not found: $CONFIG_FILE

Create it first, for example:

  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.config/restic"
  printf '%s\n' 'change-this-password' > "$HOME/.config/restic/password"
  chmod 600 "$HOME/.config/restic/password"

  cat > "$CONFIG_FILE" <<'CONF'
RESTIC_REPOSITORY=/media/$USER/YOUR_HDD/restic-laptop
RESTIC_PASSWORD_FILE=$HOME/.config/restic/password
BACKUP_SOURCES="$HOME/Documents $HOME/dotfiles $HOME/.config"
RESTIC_TAGS="laptop local"
KEEP_DAILY=7
KEEP_WEEKLY=4
KEEP_MONTHLY=6
KEEP_YEARLY=2
RESTORE_TARGET=$HOME/restore-restic
CONF
EOF
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${RESTIC_REPOSITORY:?RESTIC_REPOSITORY is required}"
: "${RESTIC_PASSWORD_FILE:?RESTIC_PASSWORD_FILE is required}"

BACKUP_SOURCES="${BACKUP_SOURCES:-$HOME/Documents $HOME/dotfiles}"
RESTIC_TAGS="${RESTIC_TAGS:-laptop local}"
KEEP_DAILY="${KEEP_DAILY:-7}"
KEEP_WEEKLY="${KEEP_WEEKLY:-4}"
KEEP_MONTHLY="${KEEP_MONTHLY:-6}"
KEEP_YEARLY="${KEEP_YEARLY:-2}"
RESTORE_TARGET="${RESTORE_TARGET:-$HOME/restore-restic}"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD_FILE

DEFAULT_EXCLUDES=(
    --exclude "$HOME/.cache"
    --exclude "$HOME/.local/share/Trash"
    --exclude "$HOME/Downloads"
    --exclude "$HOME/.var/app/*/cache"
    --exclude "$HOME/.cargo/registry"
    --exclude "$HOME/.npm"
    --exclude "$HOME/.mozilla/firefox/*.default-release/cache2"
)

read_sources() {
    local raw="$BACKUP_SOURCES"
    if [ -z "$raw" ]; then
        echo "$SCRIPT_NAME: BACKUP_SOURCES is empty" >&2
        exit 1
    fi

    local -a sources=()
    # shellcheck disable=SC2206
    sources=($raw)
    printf '%s\n' "${sources[@]}"
}

cmd_init() {
    mkdir -p "$RESTIC_REPOSITORY"
    restic init
}

cmd_backup() {
    mapfile -t sources < <(read_sources)

    echo "Backing up to: $RESTIC_REPOSITORY"
    printf 'Sources:\n'
    printf '  %s\n' "${sources[@]}"

    restic backup \
        --verbose \
        --tag "$RESTIC_TAGS" \
        "${DEFAULT_EXCLUDES[@]}" \
        "${sources[@]}"
}

cmd_snapshots() {
    restic snapshots
}

cmd_ls() {
    local latest
    latest="$(restic snapshots --latest 1 --json | sed -n 's/.*"short_id":"\([^"]*\)".*/\1/p' | head -n1)"

    if [ -z "$latest" ]; then
        echo "$SCRIPT_NAME: no snapshots found" >&2
        exit 1
    fi

    restic ls "$latest"
}

cmd_check() {
    restic check
}

cmd_unlock() {
    restic unlock
}

cmd_forget() {
    restic forget \
        --keep-daily "$KEEP_DAILY" \
        --keep-weekly "$KEEP_WEEKLY" \
        --keep-monthly "$KEEP_MONTHLY" \
        --keep-yearly "$KEEP_YEARLY" \
        --prune
}

cmd_restore() {
    mkdir -p "$RESTORE_TARGET"
    restic restore latest --target "$RESTORE_TARGET"
}

cmd_env() {
    cat <<EOF
CONFIG_FILE=$CONFIG_FILE
RESTIC_REPOSITORY=$RESTIC_REPOSITORY
RESTIC_PASSWORD_FILE=$RESTIC_PASSWORD_FILE
BACKUP_SOURCES=$BACKUP_SOURCES
RESTIC_TAGS=$RESTIC_TAGS
KEEP_DAILY=$KEEP_DAILY
KEEP_WEEKLY=$KEEP_WEEKLY
KEEP_MONTHLY=$KEEP_MONTHLY
KEEP_YEARLY=$KEEP_YEARLY
RESTORE_TARGET=$RESTORE_TARGET
EOF
}

command="${1:-help}"
shift || true

case "$command" in
    init)
        cmd_init "$@"
        ;;
    backup)
        cmd_backup "$@"
        ;;
    snapshots)
        cmd_snapshots "$@"
        ;;
    ls)
        cmd_ls "$@"
        ;;
    check)
        cmd_check "$@"
        ;;
    unlock)
        cmd_unlock "$@"
        ;;
    forget)
        cmd_forget "$@"
        ;;
    restore)
        cmd_restore "$@"
        ;;
    env)
        cmd_env "$@"
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "$SCRIPT_NAME: unknown command: $command" >&2
        usage >&2
        exit 1
        ;;
esac
