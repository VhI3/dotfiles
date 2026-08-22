# Screenshots

These images support the public GitHub README.

Currently used in the README:

- `rofi-launcher.png`
- `nvim.png`
- `theme.png`
- `desktop.svg`
- `paperless.svg`
- `workflow.svg`

Replace them with real screenshots when your desktop is in a clean state:

```bash
mkdir -p assets/screenshots
grim assets/screenshots/desktop.png
grim -g "$(slurp)" assets/screenshots/waybar.png
```

Avoid showing private documents, browser tabs, LAN IPs, email addresses, chat windows, terminal history, usernames, or hostnames.

Raw screenshots that show local details should stay untracked. The top-level `.gitignore` ignores screenshot PNGs by default and only allows the public-safe PNGs used by the README.

If ImageMagick is installed, make smaller web images:

```bash
magick assets/screenshots/desktop.png -resize 1600x assets/screenshots/desktop.webp
```
