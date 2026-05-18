# Firewall & Services

Die Firewall ist dreistufig aufgebaut:

1. **Port-Registry** (`custom.services.ports`) — jedes Service-Modul registriert seine Ports
2. **Zonen-Interfaces** (`custom.firewall.zoneInterfaces`) — weist Netzwerk-Interfaces Zonen zu
3. **Zonen-Exposition** (`custom.firewall.exposedByZone`) — weist Services Zonen zu

Die Firewall aggregiert alle Mappings und generiert `networking.firewall.interfaces.<iface>.allowedTCPPorts` / `allowedUDPPorts`.

## Beispiel: roo6

```nix
custom.firewall = {
  zoneInterfaces = {
    wan = [ "wan0" ];
    lan = [ "lan0" ];
  };
  exposedByZone = {
    lan = [ "nginx" "openssh" "gitlab" "invidious" "radarr" "jellyfin" ];
    wan = [ "nginx" "jellyfin" ];
  };
};
```

Ergebnis:

| Interface | Zone | Freigegebene TCP-Ports |
|-----------|------|----------------------|
| `lan0` | lan | 80, 443 (nginx), 22 (openssh), 8080 (gitlab), 3000 (invidious), 7878 (radarr), 8096, 8920 (jellyfin) |
| `wan0` | wan | 80, 443 (nginx), 8096, 8920 (jellyfin) |

## Service freigeben

Um einen neuen Service im LAN freizugeben, in der Host-Config (`hosts/<hostname>/default.nix`):

```nix
custom.firewall.exposedByZone.lan = [ ... "<service-name>" ];
```

Der `<service-name>` muss exakt dem Schlüssel in `custom.services.ports` entsprechen (wird vom Service-Modul gesetzt).

## Port-Registry

Jedes Service-Modul in `nixos-profiles` registriert seine Ports automatisch. Beispiel:

```nix
custom.services.ports.nginx.tcp = [ 80 443 ];
custom.services.ports.nginx.udp = [];
```

Die Registry wird von der Firewall aufgelöst — man muss nie manuell Port-Nummern in die Firewall-Config eintragen.

## Nginx Reverse Proxy

Auf roo6 läuft nginx als Reverse Proxy mit selbstsignierten Zertifikaten. Der VHost `git.roo6.lan` leitet aktuell auf den GitLab-Port weiter. Neue VHosts werden im `nginx.nix`-Modul in `nixos-profiles` ergänzt.
