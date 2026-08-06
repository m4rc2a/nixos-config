# Architektur

## Zwei-Repos

| Repo | Inhalt | Ort |
|------|--------|-----|
| `hm-config` | Geteilte Home-Manager-Module und -Profile | [Codeberg](https://codeberg.org/m4rc2a/home-manager), Flake-Input |
| **dieses Repo** | Hardware-Konfigs, System-Zuweisung, Node-Overrides, lokale `systems/` + `modules/` | [Codeberg](https://codeberg.org/m4rc2a/nixos-config) |

Kein Snowfall Lib. Alle Modul-Imports explizit.

## Verzeichnisstruktur

```
nixos-config/
├── flake.nix              # Node-Definitionen (roo6, marc-laptop, marc-desktop) + deploy-rs
├── flake.lock
├── nodes/
│   ├── roo6/
│   │   ├── default.nix              # Server-Profil + Overrides
│   │   ├── hardware-configuration.nix
│   │   ├── disk-config.nix          # disko
│   │   └── network-interfaces.nix   # MAC-Adressen, Zonen
│   ├── marc-laptop/
│   │   ├── default.nix              # Laptop-Profil + Overrides
│   │   ├── hardware-configuration.nix
│   │   └── disk-config.nix          # disko (LUKS + btrfs)
│   └── marc-desktop/
│       ├── default.nix              # Gaming-PC-Profil + Overrides
│       ├── hardware-configuration.nix
│       └── disk-config.nix          # disko
├── systems/              # Lokale Systeme (server, laptop, desktop, gaming-pc, wsl)
├── modules/              # Lokale NixOS-Module (Services, Tools, Desktop, Security, ...)
└── docs/                 # Diese Doku
```

## Systeme

Systeme bündeln lokale Module zu einer fertigen Konfiguration.

| System | Enthält |
|--------|---------|
| **server** | Basis + alle Services + Firewall |
| **laptop** | Basis + Desktop (sway, pipewire) + Virtualisierung + Gaming + Entwicklung + Sicherheit |
| **desktop** / **gaming-pc** | Basis + Desktop (plasma) + Gaming |
| **wsl** | Minimale Basis (kein Desktop, keine Services, keine Sicherheit) — Vorlage für zukünftige WSL-Installationen |

## Deployment (deploy-rs)

Hosts werden mit [deploy-rs](deploy-rs.md) deployed, das die `deploy`-Nodes/-Profile in `flake.nix` nutzt. Komfort-Kommando:

```bash
nix run .#deploy-rs -- .#<node>          # Node deployen
nix run .#deploy-rs -- --groups <group>  # Gruppe filtern (servers/laptops/desktops/all)
```

## Custom Options

Alle eigenen Optionen nutzen den `custom.`-Prefix.

| Option | Typ | Default | Beschreibung |
|--------|-----|---------|-------------|
| `custom.users.main.create` | `bool` | `true` | Haupt-User erstellen |
| `custom.users.main.name` | `str` | `"marc"` | Username |
| `custom.users.main.groups` | `listOf str` | `["wheel"]` | Zusätzliche Gruppen |

| `custom.home-manager.users.<name>` | `listOf module` | `[]` | hm-config-Module pro User |
| `custom.security.apparmor.enable` | `bool` | `false` | AppArmor aktivieren |
| `custom.security.apparmor.mode` | `enum` | `"complain"` | complain oder enforce |
| `custom.tools.yazi.flavors` | `attrsOf path` | `{}` | Yazi-Theme-Flavors |
| `custom.boot.sky1Kernel.enable` | `bool` | `false` | Sky1-Kernel mit Hardware-Patches |

## Konventionen

- **Kein Snowfall Lib** — alle Imports explizit
- **Home-Manager** als NixOS-Module integriert (`inputs.home-manager.nixosModules.home-manager`), nicht standalone
- **Home-Manager-Module** aus `hm-config` Flake-Input, nicht aus lokalem Submodul
- **`disk-config.nix`** nutzt disko — Device-Pfade vor Installation mit `lsblk -f` verifizieren
- **Firewall** über `services.<name>.openFirewall = true` oder `networking.firewall.allowedTCPPorts` in den Service-Modulen
- **Keine Defaults für maschinenspezifische Werte** — Usernamen, Koordinaten, Passwörter, SSH-Hosts müssen vom Host gesetzt werden
- **Hostnames** werden immer vom Host gesetzt (`networking.hostName`), nie vom Profil

## Gotchas

- **aarch64 = systemd-boot**: Auf roo6 ist systemd-boot aktiv (aarch64 unterstützt es seit systemd v253). Kein GRUB für aarch64-Hosts hinzufügen.
- **Heads BIOS = kein Bootloader**: Kein GRUB, kein systemd-boot, keine EFI-Partition. `/boot` ist ext4, Kernel wird via kexec geladen (siehe [Heads BIOS](heads-bios.md))
- **`custom.users.main.create = true`** auf roo6: User `marc` wird mit SSH-Key erstellt. Home-Manager läuft für `marc` und `root`.
- **home-manager leitet `specialArgs` nicht automatisch weiter**: bei Bedarf `home-manager.extraSpecialArgs` setzen (z.B. `nixos_secrets` für `marc-desktop`).
