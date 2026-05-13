# NixOS auf dem Laptop installieren (Heads BIOS)

Schritt-für-Schritt-Anleitung zur Installation von NixOS mit dieser Flake-Konfiguration auf einem Laptop mit Heads BIOS.

> Heads muss bereits geflasht sein. Der Laptop bootet über kexec — es gibt keinen herkömmlichen Bootloader, keine EFI-Partition.

---

## 1. NixOS-Live-USB erstellen

```bash
# Auf einem beliebigen Rechner:
nix run nixpkgs#nixos-generate -- --iso --flake nixpkgs#nixos
# Oder direkt ein Image herunterladen von https://nixos.org/download
# Auf USB schreiben:
dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress && sync
```

## 2. Vom Live-USB booten

USB einstecken, Laptop einschalten. Heads bootet automatisch vom USB, wenn es als erstes Boot-Gerät erkannt wird. Falls nicht: Im Heads-Menü Boot-Device auswählen.

Einloggen im Live-System als `root` (kein Passwort).

## 3. Netzwerk & SSH einrichten

Damit `nixos-anywhere` funktioniert, muss SSH erreichbar sein:

```bash
# WLAN (falls nötig):
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase "SSID" "PASSWORT")

# Passwort für root setzen, damit nixos-anywhere sich einloggen kann:
echo "root:temp" | chpasswd

# SSH aktivieren:
systemctl start sshd
```

Auf einem **zweiten Terminal** (oder von einem anderen Rechner im selben Netzwerk) verbinden:

```bash
ssh root@<ip-des-laptops>
```

> `nixos-anywhere` muss über SSH laufen — auch wenn du lokal auf dem Laptop arbeitest.

## 4. Festplatte identifizieren

```bash
lsblk -f
```

Die Device-Pfade in `hosts/marc-laptop/disk-config.nix` müssen mit der echten Hardware übereinstimmen. Aktuell steht dort:

- `/dev/sdb` — Hauptspeicher (boot + LUKS + btrfs)

Falls deine Festplatte anders heißt (z.B. `/dev/nvme0n1`), `disk-config.nix` **vor der Installation anpassen**.

## 5. Repo klonen & LUKS-Passwort vorbereiten

```bash
# Repo klonen
git clone git@codeberg.org:m4rc2a/nixos-config.git
cd nixos-config

# LUKS-Passwort-Datei erstellen (wird von disko verwendet)
echo "DEIN_PASSWORT" > /tmp/secret.key
chmod 600 /tmp/secret.key
```

> `/tmp/secret.key` wird in `disk-config.nix` als `passwordFile` referenziert. Ohne diese Datei schlägt disko fehl.

## 6. nixos-anywhere ausführen

```bash
nix run github:numtide/nixos-anywhere -- \
  --flake .#marc-laptop \
  root@localhost
```

Oder von einem anderen Rechner im Netzwerk:

```bash
nix run github:numtide/nixos-anywhere -- \
  --flake .#marc-laptop \
  root@<ip-des-laptops>
```

Was passiert dabei:
1. disko partitioniert die Festplatte (GPT: 512M ext4 `/boot` + LUKS/btrfs mit Subvolumes)
2. NixOS wird in das neue System gebaut und installiert
3. Der Activation-Script kopiert Kernel, Initrd und Cmdline nach `/boot/kexec/`

## 7. USB entfernen & erster Boot

1. Laptop ausschalten
2. USB-Stick entfernen
3. Einschalten — Heads lädt den Kernel automatisch via kexec von `/boot/kexec/`
4. LUKS-Passwort eingeben wenn der Initrd danach fragt
5. Einloggen als `marc` (Passwort ggf. über NixOS-Config gesetzt)

Falls Heads den Kernel nicht findet: Im Heads-Menü manuell `/boot/kexec/vmlinuz` auswählen.

## 8. Nach der Installation — Config anpassen & deployen

Künftig brauchst du keinen Live-USB mehr. Änderungen an der Konfiguration kannst du remote deployen:

```bash
# Config anpassen...
nixos-rebuild switch --flake .#marc-laptop --target-host root@marc-laptop.lan
```

Oder direkt auf dem Laptop:

```bash
sudo nixos-rebuild switch --flake .#marc-laptop
```

---

## Heads BIOS einrichten

Nach der NixOS-Installation muss Heads noch konfiguriert werden. Heads schützt den Boot-Prozess durch Measured Boot, signierte `/boot`-Inhalte und TPM-versiegelte Schlüssel. Ohne diese Schritte bootet Heads nur im dynamischen Modus und kann keine Integrität prüfen.

> Ausführliche Doku: https://osresearch.net/

### 1. OEM Factory Reset / Re-Ownership

Beim ersten Start nach der Installation hat Heads noch keine Schlüssel. Wähle im Hauptmenü **OEM Factory Reset / Re-Ownership**. Der Wizard fragt nacheinander alle Sicherheitskomponenten ab.

**Wichtig:** Standardwerte ablehnen und den Fragebogen vollständig durchgehen. Das passiert nur einmal.

Folgende Passphrases werden gesetzt:

| Passphrase | Empfohlene Länge | Zweck |
|------------|-------------------|-------|
| Disk Recovery Key | 6 Wörter (EFF Diceware) | LUKS-Entschlüsselung falls TPM nicht freigibt (z.B. nach Firmware-Update) |
| TPM Owner Password | 2 Wörter | Besitz des TPM |
| GPG Admin PIN | 2 Wörter | Verwaltung des USB Security Dongle (Achtung: nach 3 Fehlversuchen gesperrt!) |
| GPG User PIN | 2 Wörter | Signieren von /boot-Inhalten (Achtung: nach 3ehlversuchen gesperrt!) |
| TPM Disk Unlock Key | 3 Wörter | Passphrase beim Normalboot, um LUKS-Key aus dem TPM zu lösen |

**Tipps:**
- Keine geteilte Passphrase für alle Komponenten (Option ablehnen)
- EFF Diceware-Passphrases generieren: https://www.rempe.us/diceware/#eff
- Die Passphrases werden einmalig auf dem Bildschirm angezeigt — sicher notieren und wegsclossern

### 2. TPM konfigurieren (TOTP)

Heads nutzt TOTP (Time-based One-Time Password) um dem Nutzer zu bestätigen, dass die Firmware unverändert ist.

1. Authenticator-App auf dem Smartphone installieren (z.B. [FreeOTP+](https://f-droid.org/en/packages/org.liberty.android.freeotpplus/) oder Google Authenticator)
2. Den QR-Code scannen, den Heads nach dem Factory Reset anzeigt
3. **Uhrzeit in Heads manuell setzen:** `Options -> Set clock` (UTC/GMT). Ohne korrekte Uhrzeit schlägt die TOTP-Verifikation fehl
4. Beim nächsten Boot: TOTP-Code auf dem Bildschirm mit der App vergleichen. Stimmen sie überein, ist die Firmware unverändert

### 3. /boot signieren

Heads akzeptiert persistente Boot-Optionen nur wenn sie signiert sind. Ohne Signatur nutzt Heads den dynamischen Modus (scannt nach grub/syslinux-Konfigurationen).

1. USB Security Dongle einstecken
2. Im Heads-Menü: `Options -> Update checksums and sign all files in /boot`
3. GPG User PIN eingeben
4. Heads erzeugt `kexec_hashes.txt` (SHA256-Prüfsummen) und `kexec.sig` (Signatur aller `kexec*.txt`-Dateien)

### 4. Default Boot Option setzen

Damit Heads automatisch bootet ohne jedes Mal manuell auszuwählen:

1. Im Heads-Menü: `Options -> Boot Options -> Show boot options`
2. Den gewünschten Eintrag auswählen (z.B. den kexec-Eintrag mit `/boot/kexec/vmlinuz`)
3. Mit `d` als Default markieren
4. Bestätigen

Heads erstellt daraufhin `kexec_menu.txt` und `kexec_default.1.txt` in `/boot/`.

### 5. TPM Disk Unlock Key (optional, empfohlen)

Versiegelt einen LUKS-Schlüssel im TPM. Der Schlüssel wird nur freigegeben wenn die TPM-PCR-Werte (Firmware, Kernel-Module, LUKS-Header) mit denen zum Zeitpunkt der Versiegelung übereinstimmen. Dadurch muss beim Booten nur noch die TPM Disk Unlock Key Passphrase eingegeben werden — das LUKS-Passwort entfällt.

1. Default Boot Option setzen (siehe Schritt 4)
2. Beim Setzen des Defaults fragt Heads nach dem Disk Recovery Key (das LUKS-Passwort aus der Installation)
3. Neue TPM Disk Unlock Key Passphrase vergeben (3 Wörter)
4. GPG User PIN eingeben zum Signieren
5. LUKS-Device angeben: `/dev/sdb2` (entspricht der LUKS-Partition in `disk-config.nix`)

**Ablauf beim Normalboot:**
1. TOTP-Code prüfen
2. TPM Disk Unlock Key Passphrase eingeben
3. TPM gibt LUKS-Key frei wenn PCRs stimmen
4. System bootet automatisch durch

**Wenn die PCRs nicht stimmen** (z.B. nach Firmware-Update oder Manipulation):
- TPM verweigert die Freigabe
- Heads bietet an, stattdessen den Disk Recovery Key einzugeben
- Das ist der Sicherheitshinweis: untersuche, warum sich die Firmware geändert hat

### 6. Nach jedem NixOS-Rebuild

Jedes `nixos-rebuild switch` aktualisiert Kernel und Initrd in `/boot/kexec/`. Dadurch ändern sich die Datei-Hashes und Heads verweigert den Boot mit der Meldung dass die Hashes nicht stimmen.

Nach dem Rebuild:
1. Neustarten
2. Heads warnt: Hashes stimmen nicht mit Signatur überein
3. Im Heads-Menü: `Options -> Update checksums and sign all files in /boot` (GPG User PIN eingeben)
4. Default Boot Option neu setzen: `Options -> Boot Options -> Show boot options` -> `d`
5. Neustarten — jetzt bootet Heads normal durch

> **Hinweis:** Nur den eigenen USB Security Dongle einstecken wenn signiert wird. Andere Dongel entfernen um Konflikte zu vermeiden.

### 7. Heads Recovery Shell

Falls etwas schiefgeht, bietet Heads eine Recovery Shell: `Options -> Exit to recovery shell`. Dort stehen Tools wie `fdisk`, `mount-usb`, `gpg` und `cbmem` zur Verfügung.

Nützliche Befehle:

```bash
mount-usb                    # USB-Stick einhängen (Read-Write)
cbmem -L                     # TCPA-Event-Log anzeigen (PCR2-Messungen)
gpg --change-pin             # GPG User PIN zurücksetzen (braucht Admin PIN)
kexec-sign-config -p /boot/  # /boot manuell signieren
```

### Übersicht: Secrets in Heads

| Secret | Gespeichert in | Verlust-Folge |
|--------|---------------|---------------|
| Disk Recovery Key | LUKS-Header | Datenverlust — Festplatte nicht mehr entschlüsselbar |
| TPM Disk Unlock Key Passphrase | TPM NVRAM (versiegelt) | Muss mit Disk Recovery Key gebootet werden |
| GPG User PIN | USB Security Dongle | Kann mit Admin PIN zurückgesetzt werden |
| GPG Admin PIN | USB Security Dongle | Dongle unbrauchbar nach 3 Fehlversuchen |
| TPM Owner Password | TPM NVRAM | TPM kann nicht neu besessen werden |
| TOTP Shared Secret | TPM NVRAM (versiegelt) + Smartphone | Neues TOTP muss erzeugt werden |

---

## Architektur-Hinweise

| Thema | Detail |
|-------|--------|
| **Kein Bootloader** | Heads nutzt kexec. Kein GRUB, kein systemd-boot, keine EFI-Partition. `/boot` ist ext4. |
| **Kernel-Export** | `hardware-configuration.nix` enthält einen `activationScripts`-Eintrag, der Kernel/Initrd/Cmdline nach `/boot/kexec/` kopiert. |
| **Verschlüsselung** | LUKS auf der Root-Partition, btrfs-Subvolumes für `/`, `/home`, `/nix`, Swap. |
| **Flake-Inputs** | `nixos-profiles` (shared Module/Profile), `hm-chammy` (Home-Manager), `disko`, `home-manager`. |
| **Custom Options** | Alle eigenen Optionen nutzen `custom.`-Prefix (siehe `AGENTS.md`). |
