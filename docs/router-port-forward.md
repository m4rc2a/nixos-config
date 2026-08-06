# Router-Port-Forwarding (roo6)

Externer Zugriff auf Dienste von roo6 erfordert Port-Forwards im Heimrouter.
Diese Doku erfasst die notierten Regeln — **nicht** in NixOS konfiguriert
(Router außerhalb der Repo-Zuständigkeit).

## Ports

| Port | Dienst | Hinweis |
|------|--------|---------|
| 2222 | Forgejo git-über-SSH | Forgejo-eigenes SSH (nicht Port 22) |
| 80/443 | nginx → Web-Dienste | z.B. `git.roo6.lan`, Home Assistant |
| 2443 | SSH-Reverse-Tunnel | shelog-Rückkanal (services.ssh-reverse-tunnel) |

## Forgejo git-über-SSH (Port 2222)

`services.forgejo.settings.server.SSH_PORT = 2222` — Clone-URLs lauten dann:

```bash
git clone ssh://forgejo@git.roo6.lan:2222/<owner>/<repo>.git
# oder
git clone git@git.roo6.lan:2222:<owner>/<repo>.git
```

Im Router muss **TCP 2222** auf die interne IP von roo6 weitergeleitet werden
(dieser Port ist zusätzlich in der Firewall von roo6 geöffnet).

> Hinweis: Der Forgejo-SSH-Service nutzt einen eigenen SSH-Server — er ersetzt
> nicht den System-OpenSSH auf Port 22. Schlüssel werden in Forgejo verwaltet
> (nicht in `~/.ssh/authorized_keys`).
