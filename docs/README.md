# NixOS Config — Wiki

Dokumentation für das NixOS-Konfigurations-Setup. Zwei Repos, deklarative Config, zonenbasierte Firewall.

## Hosts

| Host | System | Profil | Besonderheiten |
|------|--------|--------|----------------|
| `roo6` | `aarch64-linux` | server | Radxa Orion O6. systemd-boot. Zonen-Firewall. |
| `marc-laptop` | `x86_64-linux` | laptop | Heads BIOS, kexec-Boot, LUKS-verschlüsselt. |
| `marc-desktop` | `x86_64-linux` | gaming-pc | Desktop-PC, systemd-boot. |

## Seiten

| Seite | Inhalt |
|-------|--------|
| [Architektur](architecture.md) | Two-Repo-Split, Custom Options, Konventionen |
| [Neuinstallation](fresh-install.md) | Bare Metal mit nixos-anywhere |
| [System aktualisieren](update-system.md) | Remote/lokal deployen, Rollback, Flake-Update |
| [Remote Deploy (deploy-rs)](deploy-rs.md) | Deployment mit deploy-rs: Nodes, Profile, Gruppen |
| [Remote Deploy](remote-deploy.md) | Sicher deployen von unterwegs, kein Zugriffsverlust |
| [marc-laptop deployen](deploy-marc-laptop.md) | Deploy/Install des Heads+LUKS-Laptops (deploy-rs / nixos-anywhere) |
| [Heads BIOS](heads-bios.md) | kexec-Boot, TOTP, TPM, Signierung, Post-Rebuild |
| [aarch64 / ARM](aarch64.md) | systemd-boot, Cross-Compile, Firmware, UART, RPi5 |
| [Two-Repo-Workflow](two-repo-workflow.md) | hm-config ändern, neues Modul hinzufügen |
| [Firewall & Services](firewall-services.md) | Zonen-Systematik, Port-Registry, Service freigeben |
