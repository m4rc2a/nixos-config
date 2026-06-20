# Remote Deploy (von unterwegs)

Config auf einem Host deployen, wenn du keinen physischen Zugriff hast und kein Root-SSH zur Verfügung steht.

## Problem

- `nixos-rebuild switch --target-host root@<host>` braucht Root-SSH
- Auf Servern ist `PermitRootLogin = "no"` die Regel
- Ein fehlgeschlagener Switch kann die SSH-Verbindung kappen — kein Zugang mehr

## Lösung: Auf dem Zielsystem bauen

Config lokal ändern, pushen, auf dem Ziel bauen und anwenden.

### Workflow

1. **Lokal**: Config ändern, committen, pushen
2. **Auf dem Zielsystem**: Repo pullen (oder direkt aus Git bauen)
3. **Drei-Stufen-Strategie**:

```bash
# Stufe 1: Nur bauen (validiert die Config, ändert nichts)
nixos-rebuild build --flake .#<hostname>

# Stufe 2: Anwenden, aber nicht persistent (nach Reboot = alte Config)
sudo nixos-rebuild test --flake .#<hostname>

# Stufe 3: Wenn alles funktioniert — persistent machen
sudo nixos-rebuild switch --flake .#<hostname>
```

### Warum `test` vor `switch`?

`nixos-rebuild test` wendet die Config an, schreibt sie aber **nicht in den Bootloader**. Wenn die neue Config SSH kaputt macht und du die Verbindung verlierst, bringt ein Reboot das System mit der **alten, funktionierenden Config** zurück. Das ist dein Safety-Net wenn du nicht vor Ort bist.

`nixos-rebuild switch` macht die Config persistent — sie überlebt einen Reboot.

### Alternativ: Direkt aus Git bauen

Falls das Repo nicht lokal ausgecheckt ist:

```bash
nixos-rebuild build --flake git+https://codeberg.org/m4rc2a/nixos-config#<hostname>
```

### Rollback

Falls `switch` bereits durchgelaufen ist und die Config Probleme macht:

```bash
# Zur vorherigen Generation wechseln
sudo nixos-rebuild switch --rollback

# Oder: Beim Reboot im GRUB-Menü eine ältere Generation wählen
```

## Wann `--target-host` trotzdem geht

Wenn der Host Root-SSH mit Key-Auth erlaubt (`PermitRootLogin = "prohibit-password"`), kannst du remote bauen und deployen:

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<host>
```

Auf roo6 ist das nicht der Fall — dort muss auf dem System selbst gebaut werden.
