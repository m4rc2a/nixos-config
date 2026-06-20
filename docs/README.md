# NixOS Config — Wiki

Dokumentation für das NixOS-Konfigurations-Setup. Zwei Repos, deklarative Config, zonenbasierte Firewall.

## Hosts

| Host | System | Profil | Besonderheiten |
|------|--------|--------|----------------|
| `roo6` | `aarch64-linux` | server | Radxa Orion O6. Läuft als root. GRUB statt systemd-boot. Zonen-Firewall. |
| `marc-laptop` | `x86_64-linux` | laptop | Heads BIOS, kexec-Boot, LUKS-verschlüsselt. |
| `wsl` | `x86_64-linux` | wsl | WSL2, separater GitLab-Repo. |
| `rpi5-webserver` | `aarch64-linux` | server | Raspberry Pi 5, separater GitLab-Repo. |

## Seiten

| Seite | Inhalt |
|-------|--------|
| [Architektur](architecture.md) | Two-Repo-Split, Custom Options, Konventionen |
| [Neuinstallation](fresh-install.md) | Bare Metal mit nixos-anywhere |
| [System aktualisieren](update-system.md) | Remote/lokal deployen, Rollback, Flake-Update |
| [Remote Deploy](remote-deploy.md) | Sicher deployen von unterwegs, kein Zugriffsverlust |
| [Heads BIOS](heads-bios.md) | kexec-Boot, TOTP, TPM, Signierung, Post-Rebuild |
| [aarch64 / ARM](aarch64.md) | GRUB-Override, Cross-Compile, Firmware, UART, RPi5 |
| [Arbeitsrechner](work-systems.md) | WSL und andere Arbeits-Systeme |
| [Two-Repo-Workflow](two-repo-workflow.md) | nixos-profiles ändern, neues Modul hinzufügen |
| [Firewall & Services](firewall-services.md) | Zonen-Systematik, Port-Registry, Service freigeben |
