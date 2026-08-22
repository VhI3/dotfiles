# Paperless Server Restore Runbook

Stand: 2026-07-20

Ziel: Paperless-ngx auf `home-server` nach einer Server-Neuinstallation sauber
wiederherstellen.

Diese Anleitung nutzt die aktuelle Server-Architektur:

```text
Server: home-server
Server IP: 192.168.1.10
Paperless URL: http://192.168.1.10:8000

/AppData
-> Docker Compose, Datenbank, Redis, Paperless-App-Daten

/mnt/Documents_1
-> aktive Dokumenten-SSD, Paperless-Media, Consume, Export

/mnt/Documents_2
-> HDD-Spiegel von Documents_1
```

## 1. Grundregel

```text
Documents_1 = Master / aktive Dokumenten-SSD
Documents_2 = exakter HDD-Spiegel
```

Nicht direkt auf `Documents_2` arbeiten. Änderungen passieren auf
`Documents_1` und werden danach gespiegelt.

Wichtig: Die Spiegelung ist kein versioniertes Backup. Wenn eine Datei auf
`Documents_1` gelöscht wird, wird sie beim nächsten Spiegeln auch auf
`Documents_2` gelöscht. Restic kommt später als versionierte Sicherung dazu.

## 2. Erwartete Laufwerke

Nach dem Einstecken der SSD und HDD auf `home-server` prüfen:

```bash
lsblk -f
```

Erwartete Labels:

```text
Documents_1 = aktive SSD
Documents_2 = HDD-Spiegel
AppData     = Server-App-Daten
```

Mounts prüfen:

```bash
findmnt /AppData
findmnt /mnt/Documents_1
findmnt /mnt/Documents_2
```

Wenn `Documents_1` oder `Documents_2` nicht gemountet sind:

```bash
sudo mkdir -p /mnt/Documents_1 /mnt/Documents_2
sudo mount LABEL=Documents_1 /mnt/Documents_1
sudo mount LABEL=Documents_2 /mnt/Documents_2
```

## 3. Erwartete Dokumentenstruktur

Auf `Documents_1`:

```text
/mnt/Documents_1
├── 00-Eingang
├── 10-Unterlagen
├── 20-Referenz
│   ├── Normen
│   ├── paperless-consume
│   ├── paperless-export
│   ├── paperless-media
│   └── regelwerke
├── 30-libraries
└── 90-Archiv
```

Ordner anlegen, falls sie fehlen:

```bash
sudo mkdir -p /mnt/Documents_1/20-Referenz/paperless-consume
sudo mkdir -p /mnt/Documents_1/20-Referenz/paperless-export
sudo mkdir -p /mnt/Documents_1/20-Referenz/paperless-media
sudo chown -R your-user:your-user /mnt/Documents_1/20-Referenz/paperless-consume
sudo chown -R your-user:your-user /mnt/Documents_1/20-Referenz/paperless-export
sudo chown -R your-user:your-user /mnt/Documents_1/20-Referenz/paperless-media
```

## 4. Paperless Export Prüfen

Vor einem Import muss ein Paperless-Export vorhanden sein:

```bash
ls -la /mnt/Documents_1/20-Referenz/paperless-export
test -f /mnt/Documents_1/20-Referenz/paperless-export/manifest.json
```

Erwartete Dateien/Ordner:

```text
archive/
originals/
thumbnails/
manifest.json
metadata.json
```

## 5. Paperless AppData-Ordner

Paperless-App-Daten liegen unter `/AppData`:

```bash
sudo mkdir -p /AppData/compose/paperless
sudo mkdir -p /AppData/paperless/{data,db,redis}
sudo chown -R "$(id -u):$(id -g)" /AppData/compose/paperless
sudo chown -R "$(id -u):$(id -g)" /AppData/paperless
```

## 6. `.env` Erstellen

```bash
cd /AppData/compose/paperless
umask 077

cat > .env <<EOF
PAPERLESS_DB_PASSWORD=$(openssl rand -base64 32)
PAPERLESS_SECRET_KEY=$(openssl rand -base64 64)
USERMAP_UID=$(id -u)
USERMAP_GID=$(id -g)
EOF
```

## 7. `compose.yml` Erstellen

Wichtig: `postgres:17` verwenden. Nicht `postgres:18`, weil PostgreSQL 18 im
Docker-Image eine andere Mount-Struktur erwartet.

```bash
cd /AppData/compose/paperless

cat > compose.yml <<'EOF'
name: paperless

services:
  broker:
    image: docker.io/library/redis:8
    restart: unless-stopped
    volumes:
      - /AppData/paperless/redis:/data

  db:
    image: docker.io/library/postgres:17
    restart: unless-stopped
    volumes:
      - /AppData/paperless/db:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: ${PAPERLESS_DB_PASSWORD}

  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: unless-stopped
    depends_on:
      - broker
      - db
      - gotenberg
      - tika
    ports:
      - "8000:8000"
    volumes:
      - /AppData/paperless/data:/usr/src/paperless/data
      - /mnt/Documents_1/20-Referenz/paperless-media:/usr/src/paperless/media
      - /mnt/Documents_1/20-Referenz/paperless-consume:/usr/src/paperless/consume
      - /mnt/Documents_1/20-Referenz/paperless-export:/usr/src/paperless/export
    environment:
      USERMAP_UID: ${USERMAP_UID}
      USERMAP_GID: ${USERMAP_GID}
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db
      PAPERLESS_DBNAME: paperless
      PAPERLESS_DBUSER: paperless
      PAPERLESS_DBPASS: ${PAPERLESS_DB_PASSWORD}
      PAPERLESS_SECRET_KEY: ${PAPERLESS_SECRET_KEY}
      PAPERLESS_TIME_ZONE: Europe/Berlin
      PAPERLESS_URL: http://192.168.1.10:8000
      PAPERLESS_ALLOWED_HOSTS: 192.168.1.10,localhost,127.0.0.1,home-server
      PAPERLESS_CSRF_TRUSTED_ORIGINS: http://192.168.1.10:8000,http://localhost:8000,http://home-server:8000
      PAPERLESS_OCR_LANGUAGE: deu+eng
      PAPERLESS_TIKA_ENABLED: 1
      PAPERLESS_TIKA_ENDPOINT: http://tika:9998
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT: http://gotenberg:3000

  gotenberg:
    image: docker.io/gotenberg/gotenberg:8
    restart: unless-stopped
    command:
      - gotenberg
      - --chromium-disable-javascript=true
      - --chromium-allow-list=file:///tmp/.*

  tika:
    image: docker.io/apache/tika:latest
    restart: unless-stopped
EOF
```

## 8. Paperless Starten

```bash
cd /AppData/compose/paperless
docker compose config
docker compose pull
docker compose up -d
docker compose ps
```

Wenn `db` neu startet, Logs prüfen:

```bash
docker compose logs --tail=80 db
```

Bekannter Fehler: Mit `postgres:18` erscheint ein Mount-/Upgrade-Hinweis.
Lösung: `postgres:17` verwenden und bei frischem Setup den leeren DB-Ordner
zurücksetzen:

```bash
docker compose down
rm -rf /AppData/paperless/db/*
sed -i 's|postgres:18|postgres:17|' compose.yml
docker compose up -d
```

## 9. Admin User Erstellen

Erst ausführen, wenn `docker compose ps` zeigt, dass `db` läuft und der
Webserver nicht ständig neu startet:

```bash
cd /AppData/compose/paperless
docker compose exec webserver python manage.py createsuperuser
```

## 10. Export Importieren

Der Export ist im Container unter `/usr/src/paperless/export` verfügbar.

```bash
cd /AppData/compose/paperless
docker compose exec webserver document_importer /usr/src/paperless/export
```

Danach Paperless im Browser öffnen:

```text
http://192.168.1.10:8000
```

Mehrere Dokumente öffnen und prüfen:

```text
PDF sichtbar?
Titel vorhanden?
Tags vorhanden?
Korrespondenten vorhanden?
Dokumenttypen vorhanden?
```

## 11. Server-SMB-Share Für Scan-Inbox

Auf `home-server` muss Samba den Consume-Ordner freigeben:

```text
Share: Paperless-Consume
Pfad:  /mnt/Documents_1/20-Referenz/paperless-consume
```

Falls `smbclient` fehlt:

```bash
sudo apt install smbclient
```

Share in `/etc/samba/smb.conf` ergänzen:

```ini
[Paperless-Consume]
   path = /mnt/Documents_1/20-Referenz/paperless-consume
   browseable = yes
   writable = yes
   guest ok = no
   create mask = 0664
   directory mask = 0775
   valid users = your-user
```

Ordnerrechte setzen:

```bash
sudo mkdir -p /mnt/Documents_1/20-Referenz/paperless-consume
sudo chown -R your-user:your-user /mnt/Documents_1/20-Referenz/paperless-consume
```

Samba neu starten und prüfen:

```bash
sudo systemctl restart smbd
smbclient -L //localhost -U your-user
```

## 12. Laptop-Client Konfiguration

Auf dem Laptop liegt die lokale Konfiguration hier:

```text
~/.config/dotfiles/paperless-tools.local.conf
```

Empfohlene Werte:

```bash
PAPERLESS_SERVER_ONLY=1
PAPERLESS_URL="http://192.168.1.10:8000"
PAPERLESS_OCR_LANGUAGE="deu+eng"

PAPERLESS_CONSUME_DIR="/mnt/paperless-consume"
PAPERLESS_CONSUME_MOUNT="/mnt/paperless-consume"
PAPERLESS_CONSUME_MUST_BE_MOUNTED=1
PAPERLESS_CONSUME_ALLOW_CREATE=0

PAPERLESS_CONSUME_SMB_SHARE="//192.168.1.10/Paperless-Consume"
PAPERLESS_SMB_CREDENTIALS_FILE="$HOME/.smb/home-server"
```

Auf dem Laptop scannen:

```bash
mount-media-shares
scan-to-paperless
```

Oder nur Paperless-Consume mounten:

```bash
mount-paperless-consume
scan-to-paperless
```

Sicherheitsverhalten: Wenn `/mnt/paperless-consume` nicht gemountet ist,
bricht `scan-to-paperless` ab und startet keinen Scan.

## 13. Media Shares Auf Dem Laptop

Lokale Datei:

```text
~/.config/dotfiles/media-shares.env
```

Empfohlene Werte:

```bash
SMB_HOST=192.168.1.10
SMB_CREDENTIALS_FILE=$HOME/.smb/home-server

FILME_SHARE=Filme
TV_SHOWS_SHARE=Series
AUDIOBOOKS_SHARE=Audiobooks
MUSIC_SHARE=Music
PAPERLESS_CONSUME_SHARE=Paperless-Consume

FILME_MOUNT=/mnt/filme
TV_SHOWS_MOUNT=/mnt/tv_show
AUDIOBOOKS_MOUNT=/mnt/audiobooks
MUSIC_MOUNT=/mnt/music
PAPERLESS_CONSUME_MOUNT=/mnt/paperless-consume
```

## 14. SSD Zu HDD Spiegelung

Wichtig: Paperless speichert Dokumentdateien auf `Documents_1`, aber Metadaten
wie Tags, Korrespondenten und Dokumenttypen liegen in der Datenbank unter
`/AppData`. Deshalb zuerst Paperless exportieren und danach spiegeln.

Empfohlen ist ein stündlicher Server-Timer:

```text
paperless-export-backup.timer
```

Dieser Timer aktualisiert:

```text
/mnt/Documents_1/20-Referenz/paperless-export
```

und startet danach den Mirror `Documents_1 -> Documents_2`.

Prüfen:

```bash
systemctl status paperless-export-backup.timer --no-pager
systemctl status paperless-export-backup.service --no-pager
journalctl -u paperless-export-backup.service -n 80 --no-pager
ls -lh /mnt/Documents_1/20-Referenz/paperless-export/manifest.json
```

Manuell starten:

```bash
sudo systemctl start paperless-export-backup.service
```

Auf `home-server` ist die einfache Spiegelung:

```text
/mnt/Documents_1/ -> /mnt/Documents_2/
```

Script:

```bash
sudo tee /usr/local/bin/mirror-documents-drives >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SRC="/mnt/Documents_1/"
DST="/mnt/Documents_2/"

if ! mountpoint -q /mnt/Documents_1; then
  echo "Documents_1 is not mounted; skipping mirror."
  exit 0
fi

if ! mountpoint -q /mnt/Documents_2; then
  echo "Documents_2 is not mounted; skipping mirror."
  exit 0
fi

echo "Mirroring $SRC -> $DST"
rsync -aHAX --delete --info=stats2,progress2 "$SRC" "$DST"
echo "Mirror finished."
EOF

sudo chmod +x /usr/local/bin/mirror-documents-drives
```

Service:

```bash
sudo tee /etc/systemd/system/mirror-documents-drives.service >/dev/null <<'EOF'
[Unit]
Description=Mirror Documents_1 SSD to Documents_2 HDD
RequiresMountsFor=/mnt/Documents_1 /mnt/Documents_2

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mirror-documents-drives
EOF
```

Timer:

```bash
sudo tee /etc/systemd/system/mirror-documents-drives.timer >/dev/null <<'EOF'
[Unit]
Description=Run Documents SSD->HDD mirror hourly

[Timer]
OnBootSec=10min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

Aktivieren:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now mirror-documents-drives.timer
sudo systemctl start mirror-documents-drives.service
```

Prüfen:

```bash
systemctl status mirror-documents-drives.timer --no-pager
systemctl status mirror-documents-drives.service --no-pager
journalctl -u mirror-documents-drives.service -n 80 --no-pager
```

Erfolgreicher Lauf sieht ungefähr so aus:

```text
status=0/SUCCESS
Mirror finished.
Number of deleted files: 0
Number of regular files transferred: 0
```

## 15. Nach Der Wiederherstellung Prüfen

Server:

```bash
docker compose -f /AppData/compose/paperless/compose.yml ps
curl -I http://localhost:8000
smbclient -L //localhost -U your-user
systemctl status mirror-documents-drives.timer --no-pager
systemctl status paperless-export-backup.timer --no-pager
```

Laptop:

```bash
mount-media-shares
findmnt /mnt/paperless-consume
check-paperless
scan-to-paperless --help
```

Browser:

```text
http://192.168.1.10:8000
```

## 16. Was Nicht Löschen

Nicht löschen, bevor Paperless im Browser geprüft wurde:

```text
/mnt/Documents_1/20-Referenz/paperless-export
/mnt/Documents_1/20-Referenz/paperless-media
/AppData/paperless/db
/AppData/paperless/data
```

Die alte Laptop-Paperless-Installation erst entfernen, wenn der Server
vollständig geprüft ist.
