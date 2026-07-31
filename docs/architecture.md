# Architektur

## Zwei-Repos

| Repo | Inhalt | Ort |
|------|--------|-----|
| `nixos-profiles` | Alle geteilten Module, Services, Profile | [Codeberg](https://codeberg.org/m4rc2a/nixos-profiles), Flake-Input |
| **dieses Repo** | Hardware-Konfigs, Profil-Zuweisung, Host-Overrides | [Codeberg](https://codeberg.org/m4rc2a/nixos-config) |

Arbeits-Rechner liegen in einem separaten GitLab-Repo.

Kein Snowfall Lib. Alle Modul-Imports explizit über `inputs.nixos-profiles.nixosProfiles.<profile>`.

## Verzeichnisstruktur

```
nixos-config/
├── flake.nix              # Host-Definitionen (roo6, marc-laptop)
├── flake.lock
├── hosts/
│   ├── roo6/
│   │   ├── default.nix              # Server-Profil + Overrides
│   │   ├── hardware-configuration.nix
│   │   ├── disk-config.nix          # disko
│   │   └── network-interfaces.nix   # MAC-Adressen, Zonen
│   └── marc-laptop/
│       ├── default.nix              # Laptop-Profil + Overrides
│       ├── hardware-configuration.nix
│       └── disk-config.nix          # disko (LUKS + btrfs)
└── docs/                            # Diese Doku
```

## Profile

Profile bündeln Module zu einer fertigen Konfiguration.

| Profil | Enthält |
|--------|---------|
| **server** | Basis + Sicherheit (doas + apparmor) + alle Services + Firewall |
| **laptop** | Basis + Desktop (sway, pipewire) + Virtualisierung + Gaming + Entwicklung + Sicherheit |
| **wsl** | Minimale Basis (kein Desktop, keine Services, keine Sicherheit) |

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

- **aarch64 = GRUB**: Profile defaulten auf systemd-boot. Aarch64 unterstützt das nicht — explizit GRUB aktivieren und systemd-boot deaktivieren (RPi-spezifische Details siehe [aarch64 / ARM](aarch64.md))
- **Heads BIOS = kein Bootloader**: Kein GRUB, kein systemd-boot, keine EFI-Partition. `/boot` ist ext4, Kernel wird via kexec geladen (siehe [Heads BIOS](heads-bios.md))
- **`custom.users.main.create = true`** auf roo6: User `marc` wird mit SSH-Key erstellt. Home-Manager läuft für `marc` und `root`.
