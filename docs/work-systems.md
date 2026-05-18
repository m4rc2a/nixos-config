# Arbeitsrechner

Arbeits-Rechner (wsl, rpi5-webserver) liegen **nicht** in diesem Repo, sondern in einem separaten GitLab-Repo.

## Workflow

```bash
git clone <repo-url>
cd nixos-config

# Config anpassen...
nixos-rebuild switch --flake .#<hostname>
```

WSL-Profile sind minimal: Basis-Module + Tools, kein Desktop, keine Services.

## Unterschiede zum privaten Repo

- Eigener `nixos-profiles`-Input (GitLab-intern)
- Keine Firewall-Zonen (WSL hat keine eigenen Netzwerk-Interfaces)
- Kein AppArmor
- Home-Manager-Module: `core` + `work` statt `core` + `desktop`
