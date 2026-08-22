#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
LAZY_ROOT="${NVIM_LAZY_ROOT:-$HOME/.local/share/nvim/lazy}"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"
NVIM_DATA_DIR="${NVIM_DATA_DIR:-$HOME/.local/share/nvim}"
NVIM_STATE_DIR="${NVIM_STATE_DIR:-$HOME/.local/state/nvim}"
TIMEOUT_SECONDS="${NVIM_REPAIR_TIMEOUT:-120}"

usage() {
  cat <<'EOF'
Usage:
  nvim-repair <command> [options] [plugin ...]

Commands:
  doctor
      Read-only check of Neovim startup, lazy-lock JSON, and Lazy plugin Git caches.

  startup
      Test whether Neovim can start headlessly.

  lazy-cache [--restore|--update|--no-lazy] [plugin ...]
      Repair common Lazy.nvim plugin-cache corruption:
      - zero-byte tracked files inside plugin Git checkouts
      - zero-byte loose Git refs such as broken tags or origin/master

  update [plugin ...]
      Shortcut for: nvim-repair lazy-cache --update [plugin ...]

  restore [plugin ...]
      Shortcut for: nvim-repair lazy-cache --restore [plugin ...]

  lspconfig-cache [--restore|--update|--no-lazy]
      Shortcut for repairing nvim-lspconfig cache corruption.

Examples:
  nvim-repair doctor
  nvim-repair startup
  nvim-repair lazy-cache neotest nvim-nio
  nvim-repair update neotest nvim-nio
  nvim-repair lspconfig-cache

Environment:
  NVIM_LAZY_ROOT=$HOME/.local/share/nvim/lazy
  NVIM_CONFIG_DIR=$HOME/.config/nvim
  NVIM_REPAIR_TIMEOUT=120
EOF
}

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

timeout_cmd() {
  timeout "$TIMEOUT_SECONDS"s "$@"
}

lazy_plugin_dirs() {
  [ -d "$LAZY_ROOT" ] || return 0

  local dir
  for dir in "$LAZY_ROOT"/*; do
    [ -d "$dir/.git" ] || continue
    basename "$dir"
  done | sort
}

normalize_plugins() {
  local -n _out_ref="$1"
  shift

  if [ "$#" -gt 0 ]; then
    _out_ref=("$@")
    return
  fi

  _out_ref=()
  while IFS= read -r plugin; do
    [ -n "$plugin" ] || continue
    _out_ref+=("$plugin")
  done < <(lazy_plugin_dirs)
}

run_nvim_startup_test() {
  require_cmd nvim
  require_cmd timeout

  log "testing Neovim startup"
  timeout 30s nvim --headless '+qa'
}

run_lazy_action() {
  local action="$1"
  shift

  [ "$action" != "none" ] || {
    log "skipping Lazy restore/update"
    return 0
  }

  local plugins=("$@")
  local lazy_cmd="+Lazy! $action"
  if [ "${#plugins[@]}" -gt 0 ]; then
    lazy_cmd="$lazy_cmd ${plugins[*]}"
  fi

  log "asking Lazy to $action ${plugins[*]:-all plugins}"
  timeout_cmd nvim --headless "$lazy_cmd" '+qa'
}

repair_plugin_cache() {
  local plugin="$1"
  local dir="$LAZY_ROOT/$plugin"
  local changed=0

  if [ ! -d "$dir/.git" ]; then
    warn "plugin cache missing or not a Git checkout: $plugin"
    return 0
  fi

  log "checking $plugin"

  local file
  while IFS= read -r file; do
    if [ -f "$dir/$file" ] && [ ! -s "$dir/$file" ]; then
      printf '  restore zero-byte tracked file: %s\n' "$file"
      git -C "$dir" show "HEAD:$file" >"$dir/$file"
      changed=1
    fi
  done < <(git -C "$dir" diff --name-only)

  local ref
  while IFS= read -r ref; do
    printf '  remove zero-byte Git ref: %s\n' "${ref#"$dir/.git/"}"
    rm -f "$ref"
    changed=1
  done < <(find "$dir/.git/refs" -type f -size 0 2>/dev/null | sort)

  if [ "$changed" -eq 1 ]; then
    log "fetching repaired refs for $plugin"
    git -C "$dir" fetch --prune --tags
  fi

  if git -C "$dir" status --short | grep -q .; then
    warn "$plugin still has non-zero local changes; left untouched"
    git -C "$dir" status --short
  fi

  local fsck_tmp
  fsck_tmp="$(mktemp)"
  git -C "$dir" fsck --no-reflogs --full >"$fsck_tmp" 2>&1 || true

  if grep -E 'invalid sha1 pointer|reference broken|bad ref' "$fsck_tmp" >/dev/null; then
    warn "$plugin still has broken Git refs"
    grep -E 'invalid sha1 pointer|reference broken|bad ref' "$fsck_tmp" | sed -n '1,80p'
  fi

  rm -f "$fsck_tmp"
}

cmd_lazy_cache() {
  require_cmd git
  require_cmd nvim
  require_cmd timeout

  local action="restore"
  local plugins=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --restore)
        action="restore"
        ;;
      --update)
        action="update"
        ;;
      --no-lazy)
        action="none"
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --*)
        die "unknown lazy-cache option: $1"
        ;;
      *)
        plugins+=("$1")
        ;;
    esac
    shift
  done

  [ -d "$LAZY_ROOT" ] || die "Lazy cache directory not found: $LAZY_ROOT"

  local selected=()
  normalize_plugins selected "${plugins[@]}"
  [ "${#selected[@]}" -gt 0 ] || die "no Lazy plugin Git caches found under $LAZY_ROOT"

  local plugin
  for plugin in "${selected[@]}"; do
    repair_plugin_cache "$plugin"
  done

  run_lazy_action "$action" "${selected[@]}"
  run_nvim_startup_test
  log "Lazy plugin cache repair finished"
}

cmd_startup() {
  run_nvim_startup_test
}

doctor_plugin_cache() {
  local plugin="$1"
  local dir="$LAZY_ROOT/$plugin"
  local issue_count=0

  [ -d "$dir/.git" ] || return 0

  local dirty_zero=0
  local file
  while IFS= read -r file; do
    if [ -f "$dir/$file" ] && [ ! -s "$dir/$file" ]; then
      dirty_zero=$((dirty_zero + 1))
    fi
  done < <(git -C "$dir" diff --name-only)

  local zero_refs=0
  zero_refs="$(find "$dir/.git/refs" -type f -size 0 2>/dev/null | wc -l)"

  local fsck_tmp
  fsck_tmp="$(mktemp)"
  git -C "$dir" fsck --no-reflogs --full >"$fsck_tmp" 2>&1 || true

  local broken_refs=0
  broken_refs="$(grep -Ec 'invalid sha1 pointer|reference broken|bad ref' "$fsck_tmp" || true)"
  rm -f "$fsck_tmp"

  issue_count=$((dirty_zero + zero_refs + broken_refs))

  if [ "$issue_count" -gt 0 ]; then
    printf '[WARN] %s: dirty-zero-files=%s zero-refs=%s broken-refs=%s\n' \
      "$plugin" "$dirty_zero" "$zero_refs" "$broken_refs"
    return 1
  fi

  return 0
}

cmd_doctor() {
  require_cmd git
  require_cmd nvim
  require_cmd timeout

  local problems=0

  log "Neovim repair doctor"
  printf 'nvim:       %s\n' "$(command -v nvim)"
  printf 'config:     %s\n' "$NVIM_CONFIG_DIR"
  printf 'data:       %s\n' "$NVIM_DATA_DIR"
  printf 'state:      %s\n' "$NVIM_STATE_DIR"
  printf 'lazy root:  %s\n' "$LAZY_ROOT"

  if [ -f "$NVIM_CONFIG_DIR/lazy-lock.json" ]; then
    if python3 -m json.tool "$NVIM_CONFIG_DIR/lazy-lock.json" >/dev/null 2>&1; then
      printf '[PASS] lazy-lock.json is valid JSON\n'
    else
      printf '[FAIL] lazy-lock.json is not valid JSON\n'
      problems=$((problems + 1))
    fi
  else
    printf '[WARN] lazy-lock.json not found under %s\n' "$NVIM_CONFIG_DIR"
  fi

  if run_nvim_startup_test >/dev/null 2>&1; then
    printf '[PASS] Neovim starts headlessly\n'
  else
    printf '[FAIL] Neovim headless startup failed\n'
    problems=$((problems + 1))
  fi

  if [ -d "$LAZY_ROOT" ]; then
    local plugin
    while IFS= read -r plugin; do
      [ -n "$plugin" ] || continue
      if ! doctor_plugin_cache "$plugin"; then
        problems=$((problems + 1))
      fi
    done < <(lazy_plugin_dirs)
  else
    printf '[WARN] Lazy cache directory missing: %s\n' "$LAZY_ROOT"
  fi

  if [ "$problems" -eq 0 ]; then
    log "doctor found no repairable Neovim cache problems"
  else
    warn "doctor found $problems problem group(s)"
    warn "try: nvim-repair lazy-cache <plugin>, or nvim-repair lazy-cache for all"
    return 1
  fi
}

main() {
  local command="${1:-}"
  if [ -z "$command" ]; then
    usage
    exit 0
  fi
  shift || true

  case "$command" in
    doctor)
      cmd_doctor "$@"
      ;;
    startup)
      cmd_startup "$@"
      ;;
    lazy-cache)
      cmd_lazy_cache "$@"
      ;;
    update)
      cmd_lazy_cache --update "$@"
      ;;
    restore)
      cmd_lazy_cache --restore "$@"
      ;;
    lspconfig-cache)
      cmd_lazy_cache nvim-lspconfig "$@"
      ;;
    help|--help|-h)
      usage
      ;;
    *)
      die "unknown command: $command"
      ;;
  esac
}

main "$@"
