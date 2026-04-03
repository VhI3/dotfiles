#!/bin/bash
set -euo pipefail

workspace=""
launch_cmd=()
app_ids=()
classes=()
class_prefixes=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --workspace)
            workspace="$2"
            shift 2
            ;;
        --app-id)
            app_ids+=("$2")
            shift 2
            ;;
        --class)
            classes+=("$2")
            shift 2
            ;;
        --class-prefix)
            class_prefixes+=("$2")
            shift 2
            ;;
        --)
            shift
            launch_cmd=("$@")
            break
            ;;
        *)
            echo "Usage: focus-or-launch.sh --workspace N [--app-id ID] [--class CLASS] [--class-prefix PREFIX] -- command ..." >&2
            exit 1
            ;;
    esac
done

if [ -z "$workspace" ] || [ "${#launch_cmd[@]}" -eq 0 ]; then
    echo "Usage: focus-or-launch.sh --workspace N [--app-id ID] [--class CLASS] [--class-prefix PREFIX] -- command ..." >&2
    exit 1
fi

match_id="$(
APP_IDS="$(printf '%s\n' "${app_ids[@]}")" \
CLASSES="$(printf '%s\n' "${classes[@]}")" \
CLASS_PREFIXES="$(printf '%s\n' "${class_prefixes[@]}")" \
python3 - <<'PY'
import json
import os
import subprocess
import sys

app_ids = {line.strip().lower() for line in os.environ.get("APP_IDS", "").splitlines() if line.strip()}
classes = {line.strip().lower() for line in os.environ.get("CLASSES", "").splitlines() if line.strip()}
class_prefixes = [line.strip().lower() for line in os.environ.get("CLASS_PREFIXES", "").splitlines() if line.strip()]

try:
    tree = json.loads(subprocess.check_output(["swaymsg", "-t", "get_tree", "-r"], text=True))
except Exception:
    raise SystemExit(0)

best_match = None

def walk(node):
    global best_match
    app_id = (node.get("app_id") or "").lower()
    win_class = ((node.get("window_properties") or {}).get("class") or "").lower()
    focused = bool(node.get("focused"))
    con_id = node.get("id")

    if con_id and (
        app_id in app_ids
        or win_class in classes
        or any(win_class.startswith(prefix) for prefix in class_prefixes)
    ):
        score = (1 if focused else 0, con_id)
        if best_match is None or score > best_match[0]:
            best_match = (score, con_id)

    for child in node.get("nodes", []):
        walk(child)
    for child in node.get("floating_nodes", []):
        walk(child)

walk(tree)

if best_match is not None:
    print(best_match[1])
PY
)"

if [ -n "$match_id" ]; then
    swaymsg "[con_id=$match_id]" focus >/dev/null
else
    swaymsg "workspace number $workspace; exec ${launch_cmd[*]}" >/dev/null
fi
