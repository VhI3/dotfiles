# Central Perk Server Bootstrap

Stand: 2026-07-27

Ziel: Wenn Ubuntu/Debian auf `home-server` neu installiert werden muss, sollen
Jellyfin, Audiobookshelf, Navidrome, Homepage und Paperless nicht wieder einzeln
von Hand zusammengesucht werden.

Die Idee ist:

```text
/AppData
-> Docker Compose Dateien und App-Daten

/DATA
-> Filme, Series, Audiobooks, Music

/mnt/Documents_1
-> Paperless Dokumente, Consume, Export

/mnt/Documents_2
-> Spiegel von Documents_1
```

Der neue Server bekommt wieder Zugriff auf diese bestehenden Laufwerke. Danach
startet Docker Compose die Apps aus `/AppData/compose`.

## Schnellstart Nach Frischer Server-Installation

Auf dem Server:

```bash
sudo apt update
sudo apt install -y git curl wget ca-certificates
git clone https://github.com/VhI3/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Erst trocken prüfen:

```bash
./bin/bootstrap-home-server.sh
```

Wenn die Ausgabe sinnvoll aussieht, wirklich anwenden:

```bash
./bin/bootstrap-home-server.sh --apply
```

Danach einmal abmelden und neu anmelden, falls Docker gerade erst installiert
wurde. Das ist nötig, damit die neue `docker`-Gruppenmitgliedschaft aktiv wird.

## Was Das Script Macht

- installiert Basiswerkzeuge wie `git`, `curl`, `rsync`, `samba`, `smbclient`
- installiert Docker und Docker Compose, falls sie fehlen
- legt Mountpoints für `/AppData`, `/mnt/Documents_1`, `/mnt/Documents_2` an
- ergänzt `/etc/fstab` über die Labels `AppData`, `Documents_1`, `Documents_2`
- legt Paperless-Verzeichnisse auf den richtigen Laufwerken an
- erstellt Paperless `.env` und `compose.yml`, falls sie fehlen
- verwendet `postgres:17` für Paperless
- richtet Samba-Shares für Medien, `Paperless-Consume`, `Documents_1` und `Documents_2` ein
- `Documents_1` ist per Samba beschreibbar; `Documents_2` ist per Samba nur lesbar
- erstellt systemd-Services für Paperless und die anderen Compose-Apps
- erstellt den stündlichen Paperless-Export-Timer
- erstellt den stündlichen Mirror-Timer `Documents_1 -> Documents_2`

## Wichtige Sicherheit

Das Script formatiert keine Laufwerke.

Das Script löscht keine App-Daten.

Bestehende Compose-Dateien bleiben erhalten. Bei Paperless wird nur
`restart: unless-stopped` zu `restart: "no"` geändert, damit Paperless nicht vor
dem Mounten von `Documents_1` startet.

## Erwartete Labels

```text
AppData
Documents_1
Documents_2
```

Prüfen mit:

```bash
lsblk -f
```

Wenn ein Label anders heißt:

```bash
APPDATA_LABEL=MeinAppData ./bin/bootstrap-home-server.sh --apply
```

## Dienste Prüfen

```bash
systemctl status home-server-compose-apps.service --no-pager
systemctl status paperless.service --no-pager
systemctl status mirror-documents-drives.timer --no-pager
docker compose ls
curl -I http://localhost:8000
```

Im Browser:

```text
http://192.168.1.10:8000
```

## Samba Prüfen

```bash
smbclient -L //localhost -U your-user
```

Falls der Samba-Benutzer fehlt:

```bash
sudo smbpasswd -a your-user
sudo systemctl restart smbd
```

Vom Laptop:

```bash
mount-media-shares
mount-paperless-consume
scan-to-paperless
```

## App-Startmodell

Paperless bekommt einen eigenen systemd-Service:

```text
paperless.service
```

Der Service wartet auf:

```text
/AppData
/mnt/Documents_1
```

Die anderen Apps werden gesammelt gestartet durch:

```text
home-server-compose-apps.service
```

Dieser Service startet vorhandene Compose-Projekte unter:

```text
/AppData/compose/homepage
/AppData/compose/jellyfin
/AppData/compose/navidrome
/AppData/compose/audiobookshelf
```

Wenn ein Compose-Ordner fehlt, wird er übersprungen.

## Paperless Backup

Paperless besteht aus zwei wichtigen Teilen:

```text
/mnt/Documents_1/20-Referenz/paperless-media
-> Originale, Archiv-PDFs, Thumbnails

/AppData/paperless/db
-> Datenbank, Tags, Korrespondenten, Dokumenttypen, Metadaten
```

Der Mirror von `Documents_1` alleine reicht deshalb nicht vollständig. Darum
legt das Bootstrap-Script zusätzlich diesen Timer an:

```text
paperless-export-backup.timer
```

Der Timer läuft stündlich und führt aus:

```bash
docker compose exec -T webserver document_exporter -d -p /usr/src/paperless/export
```

Dadurch wird der portable Paperless-Export hier aktualisiert:

```text
/mnt/Documents_1/20-Referenz/paperless-export
```

Danach wird automatisch der Mirror `Documents_1 -> Documents_2` gestartet.

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

## Mirror

Der Mirror läuft stündlich:

```bash
systemctl status mirror-documents-drives.timer --no-pager
journalctl -u mirror-documents-drives.service -n 80 --no-pager
```

Manuell starten:

```bash
sudo systemctl start mirror-documents-drives.service
```

Regel:

```text
Documents_1 ist Master.
Documents_2 ist nur Spiegel.
```

Nicht direkt auf `Documents_2` arbeiten.

## Wenn `/DATA` Nicht Gemountet Ist

Die Medien-Apps brauchen `/DATA`. Wenn der Datenträger kein Label hat, kann das
Script keinen sicheren automatischen `/etc/fstab`-Eintrag erraten.

Dann zuerst UUID prüfen:

```bash
lsblk -f
```

Danach `/etc/fstab` manuell ergänzen, zum Beispiel:

```text
UUID=DEINE-UUID /DATA ext4 defaults,nofail,x-systemd.device-timeout=30s,noatime 0 2
```

## Detail-Runbook Für Paperless

Für die vollständige Paperless-Wiederherstellung:

```bash
glow ~/dotfiles/docs/PAPERLESS-SERVER-RESTORE.md
```
