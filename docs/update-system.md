# System aktualisieren

## Deployment mit deploy-rs (empfohlen)

Hosts dieses Repos werden mit [deploy-rs](deploy-rs.md) deployed, nicht mit `nixos-rebuild --target-host`:

```bash
# Alle Profile auf einer Node deployen
nix run .#deploy-rs -- .#<node>

# Einzelnes Profil
nix run .#deploy-rs -- .#<node>.<profile>

# Gruppen-Filter (servers/laptops/desktops/personal/all)
nix run .#deploy-rs -- --groups <group>

# Dry-Run (baut + zeigt, aktiviert nicht)
nix run .#deploy-rs -- --dry-run .
```

> deploy-rs verbindet als `marc`, fragt das Sudo-Passwort ab (`interactiveSudo`) und nutzt Magic Rollback, damit fehlgeschlagene SSH-kritische Änderungen automatisch zurückgerollt werden.

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

Deploy-rs rollt bei Aktivierungsfehlern (autoRollback) bzw. wenn die Maschine nach dem Switch unerreichbar wird (magicRollback) automatisch zurück.

## Flake-Inputs aktualisieren

```bash
# Alle Inputs aktualisieren
nix flake update

# Einzelnes Input aktualisieren
nix flake lock --update-input hm-config
```

## Nächste Schritte

- Nach jedem Rebuild auf dem Laptop mit Heads BIOS: Signierung erneuern — siehe [Heads BIOS](heads-bios.md#6-nach-jedem-nixos-rebuild)
- Nach Änderungen in `hm-config`: Flake-Input updaten — siehe [Two-Repo-Workflow](two-repo-workflow.md)
