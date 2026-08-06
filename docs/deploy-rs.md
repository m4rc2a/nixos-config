# Deployment mit deploy-rs

[deploy-rs](https://github.com/serokell/deploy-rs) ist ein Nix-Flake-Deployment-Tool mit multi-profile-Support. Es ersetzt `nixos-rebuild switch --target-host` für die Hosts in diesem Repo.

## Konzepte

| Begriff | Bedeutung | In diesem Repo |
|---------|-----------|----------------|
| **Deploy** | Top-Level-Output `deploy`, enthält alle Nodes | `deploy.nodes` |
| **Node** | Ein Host (SSH-Ziel) mit `hostname` + einer Liste von Profilen | `roo6`, `marc-laptop`, `marc-desktop` |
| **Profile** | Ein deploybares Teil (Closure + Aktivierungs-Script) für einen bestimmten User | `system`, `home-marc`, `home-root` |
| **Group** | Tag zum Filtern, **kein** Mapping von Name → Nodes | `servers`, `laptops`, `desktops`, `all` |

Einstellungen werden mit Priorität **profil > node > deploy** gemerged (bestätigt in `lib.rs` / `make_deploy_data`).

### Gruppen sind Tags, keine Mappings

`groups` ist eine **Liste von Strings** (oder ein einzelner String), die auf einer Node/Profile/deploy gesetzt wird. Auswahl erfolgt ausschließlich über die CLI:

```bash
deploy --groups servers
deploy --groups desktops
```

Es gibt **kein** `deploy.groups = { name = [nodes]; }`-Mapping — das ist kein gültiger deploy-rs-Output (symmetrisch zu `interface.json`).

## Wie ein Deployment funktioniert

1. **Parsen** des Flake-Fragments `#node[.profile]` legt fest, was evaluiert wird.
2. **Lokal bauen** (Standard): `nix build <drv>^out --no-link`, dann prüfen, dass die Closure `deploy-rs-activate` und `activate-rs` enthält.
3. **Pushen**: `nix copy --substitute-on-destination --no-check-sigs --to ssh://<user>@<host> <path>`.
4. **Aktivieren per SSH**: `sudo -u <user> <closure>/activate-rs activate '<closure>' --profile-path '...' --temp-path '...' --confirm-timeout 30 --magic-rollback --auto-rollback`.
5. Der entfernte `activate`-Binary führt `nix-env -p <profil> --set <closure>` aus und läuft dann `/deploy-rs-activate` (NixOS → `switch-to-configuration switch`, home-manager → `$PROFILE/activate`).

### sudo-Regel

`sudo` wird **nur** vorangestellt, wenn `user != sshUser` ist (`lib.rs`). Das bedeutet für unser Setup:

| Profil | `user` | `sshUser` | Befehl |
|--------|--------|-----------|--------|
| `system` | `root` | `marc` | `sudo -u root ...` |
| `home-root` | `root` | `marc` | `sudo -u root ...` |
| `home-marc` | `marc` | `marc` | *(kein sudo)* |

Bei `interactiveSudo = true` fügt deploy-rs `-S -p ""` zu `sudo` hinzu und schreibt das Sudo-Passwort über `stdin` des SSH-Sessions (`cli.rs`).

### Magic Rollback (Canary-Mechanismus)

Nach der Aktivierung schreibt der entfernte Host eine Canary-Datei `deploy-rs-canary-<hash>` in `temp_path` und **wartet auf deren Löschung** innerhalb von `confirm_timeout`. Der Client startet parallel `activate-rs wait` (wartet auf die Erstellung der Canary) und ruft danach `confirm` = `ssh <host> sudo rm <canary>` auf.

- Wird die Maschine nach dem Switch **unerreichbar** (kaputtes SSH/Firewall), wird die Canary nie gelöscht → der Host **rollt nach `confirm_timeout` automatisch zurück**.
- `autoRollback` rollt zurück, wenn der Aktivierungs-Befehl selbst fehlschlägt.

Genau deshalb verhindert Magic Rollback Änderungen, die die eigene Verbindung kappen würden.

Achtung: Magic Rollback wird bei `--dry-run`, `--boot` und `--test` automatisch deaktiviert (`bin/activate.rs`), da dort die Zieldatei gar nicht geprüft werden muss.

### Profil-Pfad-Auflösung

| Fall | Pfad |
|------|------|
| `root` + `system` | `/nix/var/nix/profiles/system` |
| `root` + andere | `/nix/var/nix/profiles/per-user/root/<name>` |
| nicht-root | `/nix/var/nix/profiles/per-user/<user>/<name>` (oder XDG state) |

## Unser Setup

In `flake.nix` definiert unter `deploy`:

| Node | `hostname` | `sshUser` | `interactiveSudo` | `magicRollback` | Gruppen |
|------|------------|-----------|-------------------|-----------------|---------|
| `roo6` | `roo6` | `marc` | `true` | `true` | servers, all |
| `marc-laptop` | `marc-laptop` | `marc` | `true` | `true` | laptops, all |
| `marc-desktop` | `marc-desktop` | `marc` | `true` | `true` | desktops, all |

Profile pro Node:

- **`roo6`**: `system` (root), `home-root` (root), `home-marc` (marc) — Reihenfolge `system → home-root → home-marc`
- **`marc-laptop`**: `system` (root), `home-marc` (marc)
- **`marc-desktop`**: `system` (root), `home-marc` (marc)

Optionaler Komfort: `nix run .#deploy-rs` (verwendet das deploy-rs-Binary aus nixpkgs).

## Nutzung

```bash
# Alles deployen (alle Nodes + alle Profile)
nix run .#deploy-rs -- . .   # oder: nix run .#deploy-rs .# (ohne Fragment)

# Einzelne Node (alle Profile in profilesOrder)
nix run .#deploy-rs -- .#roo6

# Einzelnes Profil einer Node
nix run .#deploy-rs -- .#roo6.system
nix run .#deploy-rs -- .#marc-laptop.home-marc

# Gruppen-Filter (nur Nodes/Profile mit dem Tag)
nix run .#deploy-rs -- --groups servers
nix run .#deploy-rs -- --groups desktops

# Dry-Run (baut und zeigt, aktiviert nicht)
nix run .#deploy-rs -- --dry-run .#all   # 'all' ist ein Node-Fragment, kein Gruppentag!
```

> **Wichtig:** `.#all` ist **kein** gültiges Fragment. Ein Fragment ist nur `node` oder `node.profile`. Gruppen wählt man ausschließlich mit `--groups`.

`deploy .` (ohne `#`) deployt alle Nodes/Profile.

## Gotchas

- **`deploy` ist für `nix flake show`/`check` ein "unknown" flake output** — das ist normal, deploy-rs nutzt einen eigenen Output-Typ.
- **Gruppen sind Tags**, kein Mapping — siehe oben.
- **Standalone home-manager Configs** (in `hmConfigurations`) brauchen explizit `home.username`, `home.homeDirectory`, `nixpkgs.config.allowUnfree = true` und dieselben sharedModules (stylix/niri/sops) wie die NixOS-Hosts — sonst scheitert die Evaluierung.
- **home-manager NixOS-Modul leitet `specialArgs` nicht automatisch** an die per-User-HM-Module weiter — man muss `home-manager.extraSpecialArgs` setzen (siehe `marc-desktop`).
- **Magic Rollback kann nicht deaktiviert werden, wenn du SSH-kritische Änderungen machst** — für solche Fälle `--dry-run` nutzen oder ggf. `--magic-rollback false`.

## Siehe auch

- [System aktualisieren](update-system.md)
- [Remote Deploy](remote-deploy.md)
