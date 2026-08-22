# Screenshots

These SVGs are public-safe placeholders for the GitHub README.

Replace them with real screenshots when your desktop is in a clean state:

```bash
mkdir -p assets/screenshots
grim assets/screenshots/desktop.png
grim -g "$(slurp)" assets/screenshots/waybar.png
```

Avoid showing private documents, browser tabs, LAN IPs, email addresses, chat windows, or terminal history.

If ImageMagick is installed, make smaller web images:

```bash
magick assets/screenshots/desktop.png -resize 1600x assets/screenshots/desktop.webp
```
