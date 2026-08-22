#!/usr/bin/env bash
set -euo pipefail

lsblk -J -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL,TRAN,RM | python3 -c '
import json
import sys

data = json.load(sys.stdin)

print("{:<12} {:<6} {:<8} {:<12} {:<18} {:<24} {:<6} {:<2}".format(
    "NAME", "SIZE", "FSTYPE", "LABEL", "MOUNTPOINTS", "MODEL", "TRAN", "RM"
))

def show(dev, inherited=False):
    raw_rm = dev.get("rm", False)
    rm_flag = bool(raw_rm)
    rm = "1" if rm_flag else "0"
    tran = str(dev.get("tran", "") or "")
    removable = inherited or rm_flag or tran == "usb"
    if removable:
        mountpoints = dev.get("mountpoints") or []
        mount = next((m for m in mountpoints if m), "")
        print("{:<12} {:<6} {:<8} {:<12} {:<18} {:<24} {:<6} {:<2}".format(
            str(dev.get("name", "")),
            str(dev.get("size", "")),
            str(dev.get("fstype", "") or ""),
            str(dev.get("label", "") or ""),
            mount,
            str(dev.get("model", "") or ""),
            tran,
            rm,
        ))
    for child in dev.get("children", []) or []:
        show(child, removable)

for dev in data.get("blockdevices", []):
    show(dev)
'
