# marc-laptop deployen (Heads BIOS + LUKS)

> Host-spezifische Anleitung für `marc-laptop` (ThinkPad T440p, Heads BIOS, kexec-Boot, LUKS-verschlüsselt). Die generischen Workflows stehen in [deploy-rs](deploy-rs.md), [fresh-install](fresh-install.md) und [heads-bios](heads-bios.md).

## Fakten zu diesem Host

| Eigenschaft | Wert |
|-------------|------|
| Plattform | `x86_64-linux`, systemd-initrd |
| Boot | Heads BIOS → kexec (`bzImage`), kein herkömmlicher Bootloader |
| `/boot` | ext4, nicht verschlüsselt |
| Root | LUKS (`crypted`) → btrfs |
| LUKS-Device | `/dev/disk/by-partlabel/disk-main-luks` (= `...-part3` der SSD) |
| deploy-rs Node | `marc-laptop` (sshUser `marc`, Magic+Auto Rollback) |
| Profile | `system` (root), `home-marc` (marc) |
| Gruppen | `laptops`, `all` |

## 1. Update / laufender Betrieb → deploy-rs

Config-Änderungen werden mit [deploy-rs](deploy-rs.md) aufgespielt:

```bash
# erst committen & pushen (Git-Tree muss sauber sein)
git add -A && git commit -m "..." && git push

# Dry-Run — baut + zeigt, aktiviert aber nichts
nix run .#deploy-rs -- --dry-run .

# Alles deployen (alle Profile in profilesOrder: system → home-marc)
nix run .#deploy-rs -- .

# Nur ein Profil
nix run .#deploy-rs -- .#marc-laptop.system

# Filter über Gruppen-Tag
nix run .#deploy-rs -- --groups laptops
```

> deploy-rs verbindet als `marc` (`sshUser`), fragt bei Bedarf das Sudo-Passwort ab (`interactiveSudo`) und nutzt Magic Rollback (Canary + `confirm_timeout`) plus Auto-Rollback. Details: [deploy-rs.md](deploy-rs.md).

### Heads-Änderungen nach jedem Deploy sind Pflicht

Jedes Deploy/`switch` aktualisiert Kernel + Initrd in `/boot/kexec/`. Die Datei-Hashes ändern sich → **Heads lehnt Boot ab**, bis neu signiert wurde:

1. Neustart bis Heads-Menü
2. `Options -> Update checksums and sign all files in /boot` (GPG User PIN)
3. Default Boot Option neu setzen: `Options -> Boot Options -> Show boot options` → `d`
4. Neu starten

> Ausführliche Erklärung: [heads-bios.md](heads-bios.md#6-nach-jedem-nixos-rebuild)

Falls der Switch die Maschine unerreichbar macht, rollt Magic Rollback automatisch zurück (`confirm_timeout` überschritten).

## 2. Frische Installation (Bare Metal) → nixos-anywhere

Vorlage: [Neuinstallation](fresh-install.md) — mit diesen `marc-laptop`-Spezifika:

1. **Live-USB** booten, Netzwerk + Root-SSH einrichten (siehe fresh-install.md).
2. **Festplatte prüfen** (`lsblk -f`): Die Device-Pfade müssen zur tatsächlichen SSD passen (`/dev/disk/by-id/ata-TS64GMTS552T2_I*`).
3. **LUKS-Passwort**: `disk-config.nix` definiert **kein** `passwordFile` → disko fragt das LUKS-Passwort beim Formatieren **interaktiv** ab. Dieses Passwort ist später dein **Disk Recovery Key** in Heads — sorgfältig wählen.
   - Es ist KEINE zusätzliche `/tmp/secret.key`-Vorbereitung nötig.
4. **Installieren**:

   ```bash
   nix run github:numtide/nixos-anywhere -- --flake .#marc-laptop root@<ip-des-ziels>
   ```

   - disko fragt das LUKS-Passwort interaktiv in der SSH-Session ab
   - Nach der Installation bootet NixOS; `/boot/kexec`-Dateien werden vom Activation-Script eingebaut.

5. **Anschließend Heads neu einrichten** (Factory Reset/Re-ownership, TOTP, `/boot` signieren, Default Boot Option, optional TPM Disk Unlock Key) — siehe [heads-bios.md](heads-bios.md).

## Rollback

```bash
# Auf dem Zielsystem:
sudo nixos-rebuild switch --rollback

# Oder im Heads-Boot-Menü eine frühere Generation wählen (kexec-Eintrag)
```

deploy-rs rollt bei Aktivierungsfehlern (`autoRollback`) bzw. unerreichbarem Host nach überschrittenem `confirm_timeout` (`magicRollback`) automatisch auf den vorherigen Stand zurück.

## Siehe auch

- [deploy-rs](deploy-rs.md)
- [Neuinstallation](fresh-install.md)
- [Heads BIOS](heads-bios.md)
- [System aktualisieren](update-system.md)