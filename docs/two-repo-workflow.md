# Two-Repo-Workflow

Wenn ein Service-Modul, Profil oder Basis-Modul in `nixos-profiles` geändert werden muss.

## 1. Änderung in nixos-profiles

```bash
git clone git@codeberg.org:m4rc2a/nixos-profiles.git
cd nixos-profiles

# Modul ändern/erstellen...
git add -A && git commit -m "Beschreibung der Änderung"
git push origin main
```

## 2. Flake-Input im Host-Repo aktualisieren

```bash
cd ~/src/nixos-config
nix flake lock --update-input nixos-profiles
```

## 3. Deployen

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<host>
```

## Neues Service-Modul hinzufügen

1. Moduldatei in `modules/services/<name>.nix` erstellen
2. In `flake.nix` unter `nixosModules` eintragen: `service-<name> = ./modules/services/<name>.nix;`
3. Zum relevanten Profil in `profiles/` hinzufügen
4. Firewall-Port über `services.<name>.openFirewall = true` oder `networking.firewall.allowedTCPPorts` öffnen
5. Ggf. Host-spezifische Optionen setzen (Pfade, Passwörter, Koordinaten etc.)

## Regeln

- **Keine externen Inputs** in nixos-profiles — Inhalte über Options injizieren (vgl. `custom.tools.yazi.flavors`)
- **Alle Optionen unter `custom.*`** — kein Eingriff in den NixOS-Options-Namespace
- **Firewall** wird über `services.<name>.openFirewall = true` oder `networking.firewall.allowedTCPPorts` in den Service-Modulen geöffnet

## Module-Pattern

Jedes Service-Modul in `nixos-profiles` folgt demselben Aufbau:

```nix
{ lib, config, ... }: let
  cfg = config.custom.services.<name>;
in {
  options.custom.services.<name> = {
    port = lib.mkOption {
      type = lib.types.port;
      default = <default-port>;
      description = "<Service> port.";
    };
  };

  config = {
    services.<nixos-service> = {
      enable = true;
      openFirewall = true;
    };
  };
}
```

Optionen ohne Default (erforderlich) erhalten kein `default` — der Host muss sie setzen.
