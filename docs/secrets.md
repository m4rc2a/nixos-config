# nixos-secrets

Verschlüsselte Secrets für meine NixOS-Hosts mittels [sops-nix](https://github.com/Mic92/sops-nix).

## Architektur

```
nixos-secrets/            ← Dieses Repo (flake input in nixos-config)
├── .sops.yaml            ← Welche Keys dürfen entschlüsseln?
├── secrets.yaml          ← Eigentliche Secrets (sops-verschlüsselt)
└── Makefile              ← Convenience-Targets
```

Alle Secrets liegen in einer einzigen `secrets.yaml`, die mit mehreren Age-Keys
verschlüsselt ist (einer pro Host/User). Jeder Host kann nur die Secrets
entschlüsseln, für die sein Key in `.sops.yaml` eingetragen ist — sops-nix auf
dem Host kümmert sich um die Entschlüsselung zur Activation-Zeit.

## Konzepte

### Age-Keys

sops verwendet [age](https:// age-encryption.org/) zur Verschlüsselung. Jeder
Host benötigt einen Age-Key, der in `.sops.yaml` als Empfänger eingetragen ist.

**Zwei Arten von Host-Keys:**

| Typ | Verwendung | Beispiel | Key-Quelle |
|-----|-----------|----------|------------|
| **User Age Key** | marc-laptop, marc-desktop | `age1keeed6a...` | `~/.config/sops/age/keys.txt` |
| **SSH Host Key (converted)** | Server ohne GUI (roo6) | `age16msx6m...` | `/etc/ssh/ssh_host_ed25519_key` |

### User Age Key (marc-laptop, marc-desktop)

Wird per `sops.age.generateKey = true` in der NixOS-Config automatisch erzeugt
und liegt unter `/etc/sops/age/keys.txt`. Der öffentliche Schlüssel steht in
`/etc/sops/age/keys.txt.pub`.

### SSH Host Key (roo6)

Bei Servern ohne interaktiven User wird der bestehende SSH-Host-Key direkt als
Age-Key verwendet (`sops.age.sshKeyPaths`). Der SSH-Key muss dazu mit
`ssh-to-age` in das Age-Format konvertiert werden.

## Workflow: Neuen Host hinzufügen

### 1. Host-Key besorgen

**Für Hosts mit `sops.age.generateKey = true`** (marc-laptop, marc-desktop):
Nach dem ersten Deploy auf dem Zielhost:
```bash
cat /etc/sops/age/keys.txt.pub
```

**Für Hosts mit `sops.age.sshKeyPaths`** (roo6):
Von einem anderen Rechner mit SSH-Zugang:
```bash
ssh root@<host> 'cat /etc/ssh/ssh_host_ed25519_key.pub' | \
  nix shell nixpkgs#ssh-to-age -c ssh-to-age
```

### 2. Key in `.sops.yaml` eintragen

```yaml
keys:
  - &marc age1keeed6a...
  - &roo6 age16msx6m...    # ← Neuen Key hier einfügen

creation_rules:
  - path_regex: secrets\.yaml
    key_groups:
    - age:
      - *marc
      - *roo6              # ← Und hier referenzieren
```

### 3. Secrets neu verschlüsseln

```bash
make updatekeys
# oder: nix shell nixpkgs#sops -c sops updatekeys secrets.yaml
```

Dies entschlüsselt `secrets.yaml` mit dem vorhandenen Key (marc) und
verschlüsselt es neu für alle in `.sops.yaml` konfigurierten Empfänger.

### 4. Committen und auf Zielhost deployen

```bash
git add -A && git commit -m "<host>: add age key"
git push
```

## Workflow: Secrets bearbeiten

Neues Secret hinzufügen oder bestehendes ändern:

```bash
make edit-secrets
# oder: nix shell nixpkgs#sops -c sops secrets.yaml
```

Danach in `nixos-config` unter `sops.secrets` referenzieren (siehe
nächster Abschnitt).

## Secrets in nixos-config verwenden

### NixOS-Level (für Systemdienste)

```nix
{inputs, ...}: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];  # Server
  # oder: sops.age.generateKey = true;                        # Laptop

  sops.secrets.mein_secret = {
    path = "/var/lib/mein-dienst/secret.key";
    owner = "mein-dienst";
    mode = "0600";
  };
}
```

### Home-Manager-Level (für User-Secrets)

```nix
{inputs, ...}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";

  sops.secrets.mein_secret = { };
  # liegt dann unter /run/secrets/mein_secret
}
```

## Troubleshooting

### `Error getting data key: 0 successful groups required, got 0`

Der Host-Key in `.sops.yaml` stimmt nicht mit dem tatsächlichen Key auf dem
Host überein. Ursachen:

- **Platzhalter-Key wurde nie ersetzt** → Workflow "Neuen Host hinzufügen"
  durchführen
- **SSH-Host-Key hat sich geändert** (z.B. nach Neuinstallation) → Neuen Key
  holen, `.sops.yaml` aktualisieren, `make updatekeys`

### `The name ca.desrt.dconf was not provided by any .service files`

Tritt auf Headless-Servern auf, wenn stylix GUI-Targets (gtk, gnome, eog, ...)
gesetzt sind. Fix: In der Host-Config die Targets deaktivieren:

```nix
home-manager.sharedModules = [
  inputs.stylix.homeModules.stylix
  {
    stylix.targets = {
      gtk.enable = false;
      eog.enable = false;
      gnome-text-editor.enable = false;
      gnome.enable = false;
    };
  }
];
```

## Makefile-Targets

| Target | Beschreibung |
|--------|-------------|
| `make roo6-host-key` | Zeigt Anleitung zum Holen des roo6-Keys |
| `make updatekeys` | Secrets mit aktuellen Keys neu verschlüsseln |
| `make edit-secrets` | secrets.yaml mit sops öffnen |
| `make decrypt` | Entschlüsseln zur Verifikation |
