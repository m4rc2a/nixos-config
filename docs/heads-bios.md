# Heads BIOS

> Heads muss bereits geflasht sein. Der Laptop bootet über kexec — es gibt keinen herkömmlichen Bootloader, keine EFI-Partition.

## Installations-Unterschiede

- `/boot` ist ext4 (nicht vfat/EFI)
- Kein GRUB, kein systemd-boot — Heads lädt den Kernel via kexec von `/boot/kexec/`
- Der NixOS Activation-Script exportiert Kernel, Initrd und Cmdline automatisch nach `/boot/kexec/`
- Die `disk-config.nix` verwendet LUKS mit btrfs-Subvolumes

Die generische Installation (Live-USB, SSH, nixos-anywhere) ist identisch mit [Neuinstallation](fresh-install.md).

## Heads einrichten

Nach der NixOS-Installation muss Heads konfiguriert werden. Heads schützt den Boot-Prozess durch Measured Boot, signierte `/boot`-Inhalte und TPM-versiegelte Schlüssel.

> Heads benötigt eine `grub.cfg` in `/boot/grub/`, um die `/boot`-Partition als Boot-Device zu erkennen. Das NixOS Activation-Script erzeugt diese Datei automatisch zusammen mit den kexec-Boot-Dateien. Es wird kein GRUB-Paket installiert — die `grub.cfg` dient nur als Kompatibilitätsschicht.

> Ausführliche Doku: https://osresearch.net/

### 1. OEM Factory Reset / Re-ownership

Beim ersten Start hat Heads noch keine Schlüssel. Im Hauptmenü **OEM Factory Reset / Re-ownership** wählen. Der Wizard fragt alle Sicherheitskomponenten ab.

**Wichtig:** Standardwerte ablehnen und den Fragebogen vollständig durchgehen. Das passiert nur einmal.

| Passphrase | Empfohlene Länge | Zweck |
|------------|-------------------|-------|
| Disk Recovery Key | 6 Wörter (EFF Diceware) | LUKS-Entschlüsselung falls TPM nicht freigibt |
| TPM Owner Password | 2 Wörter | Besitz des TPM |
| GPG Admin PIN | 2 Wörter | Verwaltung des USB Security Dongle (nach 3 Fehlversuchen gesperrt!) |
| GPG User PIN | 2 Wörter | Signieren von /boot-Inhalten (nach 3 Fehlversuchen gesperrt!) |
| TPM Disk Unlock Key | 3 Wörter | Passphrase beim Normalboot zum Lösen des LUKS-Keys aus dem TPM |

**Tipps:**
- Keine geteilte Passphrase für alle Komponenten (Option ablehnen)
- EFF Diceware-Passphrases generieren: https://www.rempe.us/diceware/#eff
- Passphrases werden einmalig auf dem Bildschirm angezeigt — sicher notieren und wegschließen

### 2. TPM konfigurieren (TOTP)

Heads nutzt TOTP (Time-based One-Time Password) um dem Nutzer zu bestätigen, dass die Firmware unverändert ist.

1. Authenticator-App installieren (z.B. [FreeOTP+](https://f-droid.org/en/packages/org.liberty.android.freeotpplus/))
2. Den QR-Code scannen, den Heads nach dem Factory Reset anzeigt
3. **Uhrzeit in Heads manuell setzen:** `Options -> Set clock` (UTC/GMT). Ohne korrekte Uhrzeit schlägt die TOTP-Verifikation fehl
4. Beim nächsten Boot: TOTP-Code auf dem Bildschirm mit der App vergleichen. Stimmen sie überein, ist die Firmware unverändert

### 3. /boot signieren

1. USB Security Dongle einstecken
2. Im Heads-Menü: `Options -> Update checksums and sign all files in /boot`
3. GPG User PIN eingeben
4. Heads erzeugt `kexec_hashes.txt` (SHA256-Prüfsummen) und `kexec.sig` (Signatur)

### 4. Default Boot Option setzen

1. Im Heads-Menü: `Options -> Boot Options -> Show boot options`
2. Den gewünschten Eintrag auswählen (z.B. den kexec-Eintrag mit `/boot/kexec/vmlinuz`)
3. Mit `d` als Default markieren
4. Bestätigen

Heads lädt daraufhin den Default-Eintrag aus `/boot/kexec_menu.txt` und `/boot/kexec_default.1.txt`. Diese Dateien werden automatisch vom NixOS Activation-Script erzeugt.

### 5. TPM Disk Unlock Key (optional, empfohlen)

Versiegelt einen LUKS-Schlüssel im TPM. Der Schlüssel wird nur freigegeben wenn die TPM-PCR-Werte mit denen zum Zeitpunkt der Versiegelung übereinstimmen. Dadurch muss beim Booten nur noch die TPM Disk Unlock Key Passphrase eingegeben werden — das LUKS-Passwort entfällt.

1. Default Boot Option setzen (siehe Schritt 4)
2. Beim Setzen des Defaults fragt Heads nach dem Disk Recovery Key (das LUKS-Passwort aus der Installation)
3. Neue TPM Disk Unlock Key Passphrase vergeben (3 Wörter)
4. GPG User PIN eingeben zum Signieren
5. LUKS-Device angeben: `/dev/disk/by-partlabel/disk-main-luks` (entspricht der LUKS-Partition in `disk-config.nix`; GPT-Reihenfolge: biosBoot→part1, boot→part2, luks→part3)

**Ablauf beim Normalboot:**
1. TOTP-Code prüfen
2. TPM Disk Unlock Key Passphrase eingeben
3. TPM gibt LUKS-Key frei wenn PCRs stimmen
4. System bootet automatisch durch

**Wenn die PCRs nicht stimmen** (z.B. nach Firmware-Update oder Manipulation):
- TPM verweigert die Freigabe
- Heads bietet an, stattdessen den Disk Recovery Key einzugeben
- Das ist der Sicherheitshinweis: untersuche, warum sich die Firmware geändert hat

> **NixOS-seitig:** `boot.initrd.luks.devices.crypted.keyFile = "/secret.key"` (systemd-initrd). Fehlt der Key (kein `/secret.key` injiziert, z. B. DRK-Fallback), setzt `systemd-cryptsetup` `key_file = NULL; continue;` (`cryptsetup.c`, `verb_attach`) und fragt stattdessen **interaktiv nach dem LUKS-Passwort** — kein Boot-Abbruch, kein Freeze.

### 6. Nach jedem NixOS-Rebuild

Jedes `nixos-rebuild switch` aktualisiert Kernel und Initrd in `/boot/kexec/`. Die Datei-Hashes ändern sich und Heads verweigert den Boot.

Nach dem Rebuild:
1. Neustarten
2. Heads warnt: Hashes stimmen nicht mit Signatur überein
3. Im Heads-Menü: `Options -> Update checksums and sign all files in /boot` (GPG User PIN eingeben)
4. Default Boot Option neu setzen: `Options -> Boot Options -> Show boot options` -> `d`
5. Neustarten — jetzt bootet Heads normal durch

> **Hinweis:** `kexec_menu.txt` und `kexec_default.1.txt` werden vom NixOS Activation-Script automatisch aktualisiert. Nur die Signatur muss nach jedem Rebuild erneuert werden.

> **Hinweis:** Nur den eigenen USB Security Dongle einstecken wenn signiert wird. Andere Dongles entfernen um Konflikte zu vermeiden.

### 7. Heads Recovery Shell

Falls etwas schiefgeht: `Options -> Exit to recovery shell`.

```bash
mount-usb                    # USB-Stick einhängen (Read-Write)
cbmem -L                     # TCPA-Event-Log anzeigen (PCR2-Messungen)
gpg --change-pin             # GPG User PIN zurücksetzen (braucht Admin PIN)
kexec-sign-config -p /boot/  # /boot manuell signieren
```

### Secrets in Heads

| Secret | Gespeichert in | Verlust-Folge |
|--------|---------------|---------------|
| Disk Recovery Key | LUKS-Header | Datenverlust — Festplatte nicht mehr entschlüsselbar |
| TPM Disk Unlock Key Passphrase | TPM NVRAM (versiegelt) | Muss mit Disk Recovery Key gebootet werden |
| GPG User PIN | USB Security Dongle | Kann mit Admin PIN zurückgesetzt werden |
| GPG Admin PIN | USB Security Dongle | Dongle unbrauchbar nach 3 Fehlversuchen |
| TPM Owner Password | TPM NVRAM | TPM kann nicht neu besessen werden |
| TOTP Shared Secret | TPM NVRAM (versiegelt) + Smartphone | Neues TOTP muss erzeugt werden |
