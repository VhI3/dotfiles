# Notes

## Chrome / GitHub Desktop / XWayland GPU fix

If apps launched via XWayland crash or show GPU errors, add to `/etc/environment`:

```
LIBVA_DRIVER_NAME=disable
```

Then reload:
```bash
source /etc/environment
```

## Markdown preview in Neovim (peek.nvim)

Requires Deno (installed via `layers/01-base.sh`) and a Chromium-based browser.

Open preview:
```
:PeekOpen
```
