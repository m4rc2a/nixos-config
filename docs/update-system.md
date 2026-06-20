# System aktualisieren

## Remote (empfohlen)

```bash
# Config bauen und deployen
nixos-rebuild switch --flake .#<hostname> --target-host root@<host>

# Dry-run (nur bauen, nicht anwenden)
nixos-rebuild build --flake .#<hostname>
```

> **Hinweis:** `--target-host` braucht Root-SSH. Auf Hosts mit `PermitRootLogin = "no"` (z.B. roo6) muss auf dem Zielsystem selbst gebaut werden — siehe [Remote Deploy](remote-deploy.md).

## Lokal auf dem Zielsystem

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Rollback

```bash
# Auf dem Zielsystem:
sudo nixos-rebuild switch --rollback

# Oder im Boot-Menü eine ältere Generation wählen
```

## Flake-Inputs aktualisieren

```bash
# Alle Inputs aktualisieren
nix flake update

# Einzelnes Input aktualisieren
nix flake lock --update-input nixos-profiles
```

## Nächste Schritte

- Nach jedem Rebuild auf dem Laptop mit Heads BIOS: Signierung erneuern — siehe [Heads BIOS](heads-bios.md#6-nach-jedem-nixos-rebuild)
- Nach Änderungen in `nixos-profiles`: Flake-Input updaten — siehe [Two-Repo-Workflow](two-repo-workflow.md)
