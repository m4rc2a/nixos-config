# Neuinstallation (Bare Metal)

Neuinstallation auf nacktem Metall mit `nixos-anywhere`. Der Ablauf ist für alle Architekturen gleich — architekturspezifische Besonderheiten stehen in [Heads BIOS](heads-bios.md) und [aarch64 / ARM](aarch64.md).

## 1. NixOS-Live-USB erstellen

```bash
# Auf einem beliebigen Rechner:
nix run nixpkgs#nixos-generate -- --iso --flake nixpkgs#nixos
# Oder Image von https://nixos.org/download laden

# Auf USB schreiben:
dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress && sync
```

## 2. Vom Live-USB booten

USB einstecken, Boot-Reihenfolge anpassen, ins Live-System booten. Als `root` einloggen (kein Passwort).

## 3. Netzwerk & SSH einrichten

`nixos-anywhere` braucht SSH-Zugang:

```bash
# WLAN (falls nötig):
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase "SSID" "PASSWORT")

# Root-Passwort setzen:
echo "root:temp" | chpasswd

# SSH aktivieren:
systemctl start sshd
```

Auf einem zweiten Rechner im selben Netzwerk verbinden:

```bash
ssh root@<ip-des-ziels>
```

> `nixos-anywhere` muss über SSH laufen — auch bei lokaler Arbeit auf dem Zielsystem.

## 4. Festplatte identifizieren

```bash
lsblk -f
```

Die Device-Pfade in `nodes/<hostname>/disk-config.nix` müssen mit der echten Hardware übereinstimmen. Vor der Installation anpassen falls nötig.

## 5. LUKS-Passwort vorbereiten (falls verschlüsselt)

```bash
echo "DEIN_PASSWORT" > /tmp/secret.key
chmod 600 /tmp/secret.key
```

> `/tmp/secret.key` wird in `disk-config.nix` als `passwordFile` referenziert. Ohne diese Datei schlägt disko fehl.

## 6. nixos-anywhere ausführen

```bash
nix run github:numtide/nixos-anywhere -- \
  --flake .#<hostname> \
  root@<ip-des-ziels>
```

Was passiert:
1. disko partitioniert die Festplatte
2. NixOS wird gebaut und installiert
3. System bootet in die neue Konfiguration

## 7. Erster Boot

1. USB entfernen, System neustarten
2. Ggf. LUKS-Passwort eingeben
3. Einloggen (User/Passwort je nach Host-Config)

## 8. Nach der Installation

Künftig brauchst du keinen Live-USB mehr. Änderungen an der Konfiguration kannst du remote deployen:

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<host>
```

Siehe auch [System aktualisieren](update-system.md).
