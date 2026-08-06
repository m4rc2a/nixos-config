# Two-Repo-Workflow

Wenn ein Home-Manager-Modul oder -Profil in `hm-config` geändert werden muss.

## 1. Änderung in hm-config

```bash
git clone git@codeberg.org:m4rc2a/home-manager.git
cd home-manager

# Modul ändern/erstellen...
git add -A && git commit -m "Beschreibung der Änderung"
git push origin main
```

## 2. Flake-Input im Host-Repo aktualisieren

```bash
cd ~/src/nixos-config
nix flake lock --update-input hm-config
```

## 3. Deployen

```bash
nix run .#deploy-rs -- .#<node>
```

## Neues Home-Manager-Modul hinzufügen

1. Moduldatei in `hm-config/modules/<name>.nix` erstellen
2. In `hm-config` zum relevanten Profil in `modules/<profil>.nix` oder `profiles/` hinzufügen
3. Auf Host-Seite unter `home-manager.users.<name>.imports` referenzieren oder in `hmConfigurations` in `flake.nix` aufnehmen

## NixOS-Modul oder lokales System ändern (dieses Repo)

Für NixOS-Services, Tools, Desktop-Module o.ä. sind die Module **lokal** in `modules/` und die Systeme in `systems/`:

1. Modul erstellen/ändern: `modules/services/<name>.nix` etc.
2. Zum System-Import in `systems/<system>.nix` hinzufügen
3. Firewall-Port über `services.<name>.openFirewall = true` oder `networking.firewall.allowedTCPPorts` öffnen
4. Lokales `nixos-rebuild build --flake .#<hostname>` zum Testen, dann deployen

## Regeln

- **Home-Manager (hm-config) vs NixOS (lokal)**: geteilte HM-Module gehören in `hm-config`; NixOS-Module, Services und Systeme gehören in dieses Repo unter `modules/` bzw. `systems/`
- **Firewall** wird über `services.<name>.openFirewall = true` oder `networking.firewall.allowedTCPPorts` in den Service-Modulen geöffnet

## Module-Pattern

Jedes lokale Service-Modul in `modules/services/` folgt diesem Aufbau:

```nix
{ lib, config, ... }: let
  cfg = config.services.<name>;
in {
  services.<nixos-service> = {
    enable = true;
    openFirewall = true;
  };
}
```
