#!/usr/bin/env bash
set -euo pipefail

target_mac="${KEYCHRON_BT_MAC:-}"
mode="connect"
restore_pairable=""

usage() {
    cat <<'EOF'
Usage: connect-keychron [--pair | --status] [--mac ADDRESS]

Reconnect the Keychron found in BlueZ's known device list.

Options:
  --pair         Scan and pair if no valid pairing/bond exists, then connect.
  --status       Show the saved pairing/connection state without changing it.
  --mac ADDRESS  Select a keyboard explicitly (also KEYCHRON_BT_MAC).
  -h, --help     Show this help.

Before --pair: switch the keyboard to BT and hold Fn+1 for about 4 seconds
until the indicator flashes. If a passkey is shown, type it on the Keychron
and press Enter. Use a short Fn+1 press to select that slot on later reconnects.
EOF
}

die() {
    printf 'connect-keychron: %s\n' "$*" >&2
    exit 1
}

bt() {
    timeout --foreground 25 bluetoothctl "$@"
}

property() {
    awk -v name="$1:" '$1 == name { print $2; exit }'
}

cleanup() {
    if [ -n "$restore_pairable" ]; then
        bt pairable "$restore_pairable" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

while [ "$#" -gt 0 ]; do
    case "$1" in
        --pair|--status)
            [ "$mode" = "connect" ] || die "choose either --pair or --status"
            mode="${1#--}"
            ;;
        --mac)
            [ "$#" -ge 2 ] || die "--mac requires a Bluetooth address"
            target_mac="$2"
            shift
            ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done

command -v bluetoothctl >/dev/null 2>&1 || die "bluetoothctl is missing; install the bluez package"
command -v timeout >/dev/null 2>&1 || die "timeout is missing; install coreutils"
if [ -n "$target_mac" ] && ! [[ "$target_mac" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
    die "invalid Bluetooth address: $target_mac"
fi

if ! controller_info="$(bt show)" || ! grep -q '^Controller ' <<< "$controller_info"; then
    die "no Bluetooth controller available; check systemctl status bluetooth and rfkill list bluetooth"
fi

if [ "$mode" != "status" ] && [ "$(property Powered <<< "$controller_info")" != "yes" ]; then
    bt power on || die "cannot power on Bluetooth; check rfkill and the Bluetooth service"
fi

if [ "$mode" = "pair" ]; then
    echo "Put the keyboard in BT mode and hold Fn+1 until the indicator flashes."
    if [ "$(property Pairable <<< "$controller_info")" = "no" ]; then
        restore_pairable="no"
        bt pairable on || die "cannot enable pairing on the controller"
    fi
    echo "Scanning for the keyboard for 8 seconds..."
    bluetoothctl --timeout 8 scan on >/dev/null || die "Bluetooth discovery failed"
fi

if [ -z "$target_mac" ]; then
    devices="$(bt devices)" || die "cannot list Bluetooth devices"
    mapfile -t candidates < <(awk '$1 == "Device" && tolower($0) ~ /keychron/ { print $2 }' <<< "$devices")
    case "${#candidates[@]}" in
        0) die "no Keychron found; put it in pairing mode and run connect-keychron --pair" ;;
        1) target_mac="${candidates[0]}" ;;
        *) die "multiple Keychron devices found; use --mac ADDRESS (see bluetoothctl devices)" ;;
    esac
fi

info="$(bt info "$target_mac")" || die "keyboard not found; run --pair while its indicator is flashing"
grep -qi "^Device $target_mac " <<< "$info" || die "keyboard not found; run --pair while its indicator is flashing"
if [ "$mode" = "status" ]; then
    printf '%s\n' "$info"
    exit 0
fi
[ "$(property Blocked <<< "$info")" != "yes" ] || die "this keyboard is blocked; review its Bluetooth settings before reconnecting"

if [ "$(property Paired <<< "$info")" != "yes" ] || [ "$(property Bonded <<< "$info")" != "yes" ]; then
    [ "$mode" = "pair" ] || die "the saved pairing/bond is missing; switch to BT, hold Fn+1, then run connect-keychron --pair"
    echo "Pairing. If a passkey appears, type it on the Keychron and press Enter."
    timeout --foreground 90 bluetoothctl --agent KeyboardDisplay pair "$target_mac" || die "pairing failed or timed out; put the keyboard back in pairing mode and retry"
    info="$(bt info "$target_mac")"
    [ "$(property Paired <<< "$info")" = "yes" ] && [ "$(property Bonded <<< "$info")" = "yes" ] || die "pairing did not save a valid bond; please retry --pair"
fi

if [ "$(property Trusted <<< "$info")" != "yes" ]; then
    bt trust "$target_mac" || die "could not trust the paired keyboard"
fi
if [ "$(property Connected <<< "$info")" != "yes" ]; then
    bt connect "$target_mac" || die "connection failed; check BT mode, battery, and the selected Fn+1/2/3 slot"
fi

info="$(bt info "$target_mac")"
[ "$(property Connected <<< "$info")" = "yes" ] || die "the keyboard is still disconnected"
for state in Paired Bonded Trusted; do
    [ "$(property "$state" <<< "$info")" = "yes" ] || die "connection did not preserve $state: yes; check --status"
done
printf 'Keychron connected over Bluetooth (%s); pairing and bond verified.\n' "$target_mac"
