# Router-Port-Forwarding (roo6)

roo6 hängt hinter einer Fritzbox und hat **keinen öffentlichen IP-Zugang**.
Externer Zugriff läuft deshalb **ausschließlich über den SSH-Reverse-Tunnel
zu shelog** (autossh) — also **kein** Port-Forward im Heimrouter nötig.

Diese Doku erfasst die Ports/Flows im Überblick — **nicht** im Router
konfiguriert (Router außerhalb der Repo-Zuständigkeit).

## Reverse-Tunnel zu shelog (roo6 → shel:stratum0.org)

| Remote-Port (shelog) | lokales Ziel (roo6) | Zweck |
|----------------------|---------------------|-------|
| 2443 | `localhost:22` | SSH zu roo6 (deploy-rs via `home`-Alias) |
| 8443 | `localhost:443` | Caddy (alle Web-Subdomains), hierüber läuft der Web-Zugriff |

→ verdrahtet in `nodes/roo6/default.nix`
(`custom.services.ssh-reverse-tunnel.extraReverseForwards`).

## Web-Zugriff von Clients (ohne Ports im Kopf)

- Client läuft `systemd.service roo6-web-tunnel`:
  `ssh -L 127.0.0.1:443:127.0.0.1:8443 -p 20022 -l marc shelog.stratum0.org`
  (Modul `modules/services/roo6-web-tunnel.nix`).
- `/etc/hosts` mappt die Subdomains (plus Apex) auf `127.0.0.1` — **kein öffentliches DNS**
  (es gibt keinen öffentlichen A-Record / Endpunkt; Auflösung ist bewusst hosts-basiert).
- Dann greift man per Hostname zu: `https://git.zander.cloud`, `https://hass.zander.cloud`, …

| Subdomain | ro6-Backend |
|-----------|-------------|
| `git.zander.cloud` | `127.0.0.1:3000` (Forgejo) |
| `hass.zander.cloud` | `127.0.0.1:8123` (Home Assistant) |
| `jellyfin.zander.cloud` | `127.0.0.1:8096` |
| `invidious.zander.cloud` | `127.0.0.1:3001` |
| `radarr.zander.cloud` | `127.0.0.1:7878` |

TLS: **Caddy interne CA** (`tls internal` in `modules/services/caddy.nix`), Root-CA
committet in `modules/certs/caddy-roo6-root.crt`. Clients vertrauen der CA via
`security.pki.certificateFiles` (in `roo6-web-tunnel.nix`). Zertifikate sind
nur lokal vertraut — ausreichend, da der Zugriff ausschließlich tunnelt.

**Neues Gerät braucht immer alle drei:** ① hosts-Eintrag `*.zander.cloud` → `127.0.0.1`,
② Tunnel-Service (`roo6-web-tunnel`), ③ CA-Trust (`caddy-roo6-root.crt`).

## Forgejo git-über-TLS (empfohlen)

Forgejo-`DOMAIN`/`ROOT_URL` sind auf `git.zander.cloud` gesetzt. Klonen
läuft über **HTTPS durch Caddy** (Port 8443-Tunnel), kein separater SSH-Port:

```bash
git clone https://git.zander.cloud/<owner>/<repo>.git
```