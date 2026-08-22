#!/bin/bash

if command -v nala >/dev/null 2>&1; then
    PKG_MGR="nala"
else
    PKG_MGR="apt"
fi

pm_update() {
    sudo "$PKG_MGR" update
}

pm_upgrade() {
    sudo "$PKG_MGR" upgrade -y
}

pm_install() {
    sudo "$PKG_MGR" install -y "$@"
}

pm_remove() {
    sudo "$PKG_MGR" remove -y "$@"
}
