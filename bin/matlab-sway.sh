#!/usr/bin/env bash
set -euo pipefail

MATLABROOT="$HOME/.opt/MATLAB/R2024a"

# Clean environment that commonly breaks the desktop UI or OpenGL.
unset LD_LIBRARY_PATH
unset JAVA_TOOL_OPTIONS
unset QT_PLUGIN_PATH
unset QT_QPA_PLATFORMTHEME

# Java/AWT and helper UIs behave better through XWayland in Sway.
export _JAVA_AWT_WM_NONREPARENTING=1
export GDK_BACKEND=x11
# Restore the JOGL workaround MATLAB needs under Sway/XWayland.
export JAVA_TOOL_OPTIONS="-Djogl.disable.openglarbcontext=1"

# Prefer Mesa on Intel while keeping hardware acceleration enabled.
export MESA_LOADER_DRIVER_OVERRIDE=iris
export LIBGL_ALWAYS_SOFTWARE=0
export MESA_GLX_FORCE_GLX_VENDOR_LIBRARY=mesa
export __GLX_VENDOR_LIBRARY_NAME=mesa

exec "$MATLABROOT/bin/matlab" -desktop -nosoftwareopengl "$@"
