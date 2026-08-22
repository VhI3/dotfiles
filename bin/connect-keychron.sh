#!/usr/bin/env bash
set -euo pipefail

MAC="${KEYCHRON_BT_MAC:-6C:93:08:61:16:7E}"

bluetoothctl <<EOF
power on
agent on
default-agent
trust ${MAC}
connect ${MAC}
EOF
