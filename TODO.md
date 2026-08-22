# TODO

## Paperless Scanning Automation

### Investigate Scanner Hardware Button

Current state:

- Scanner detected by SANE as `Brother MFC-L3770CDW series`.
- Network scanner paths currently visible:
  - `escl:http://192.168.1.50:80`
  - `airscan:e0:Brother MFC-L3770CDW series`
- `scanbd` was tested and removed again because hardware button events did not work reliably with this Brother network scanner setup.

Goal:

```text
scanner button -> scanbd -> scan-to-paperless -> Paperless consume folder
```

Historical test:

```bash
sudo nala install scanbd
systemctl status scanbd
scanimage -L
```

Notes:

- This only works if the Brother scanner exposes button events through SANE.
- Network scanners often scan well but may not always expose hardware buttons cleanly.
- Prefer the server-side consume-folder workflow below.

### Long-Term Server-Side Consume Folder

Preferred long-term design:

```text
scanner/printer -> SMB scan inbox on home-server -> Paperless consume/import
```

Target idea:

```text
Server path:
/DATA/Documents/Paperless/consume

Paperless container path:
/usr/src/paperless/consume

Optional SMB share:
//home-server/Paperless-Consume
```

Why this is better:

- scanning does not depend on the laptop being on
- the printer can send scans directly to the server
- Paperless imports documents automatically
- the laptop is only needed for review, search, and metadata cleanup

Implementation outline:

```text
1. Create /DATA/Documents/Paperless/consume on home-server.
2. Export it as an SMB share, for example Paperless-Consume.
3. Update the Paperless Docker Compose consume volume to use that server path.
4. Configure the printer web interface for Scan-to-SMB if supported.
5. Test with one simple PDF scan.
6. Keep NAPS2 / paperless-gui as a fallback path from the laptop.
```

Open question:

```text
Does the Brother MFC-L3770CDW support Scan-to-SMB / Scan-to-Network-Folder in the current firmware and network setup?
```
