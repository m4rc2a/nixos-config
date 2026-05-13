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

## Architektur-Hinweise

| Thema | Detail |
|-------|--------|
| **Kein Bootloader** | Heads nutzt kexec. Kein GRUB, kein systemd-boot, keine EFI-Partition. `/boot` ist ext4. |
| **Kernel-Export** | `hardware-configuration.nix` enthält einen `activationScripts`-Eintrag, der Kernel/Initrd/Cmdline nach `/boot/kexec/` kopiert. |
| **Verschlüsselung** | LUKS auf der Root-Partition, btrfs-Subvolumes für `/`, `/home`, `/nix`, Swap. |
| **Flake-Inputs** | `nixos-profiles` (shared Module/Profile), `hm-chammy` (Home-Manager), `disko`, `home-manager`. |
| **Custom Options** | Alle eigenen Optionen nutzen `custom.`-Prefix (siehe `AGENTS.md`). |
