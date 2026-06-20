# aarch64 / ARM

Aarch64-spezifische Besonderheiten für alle ARM-Hosts (roo6, rpi5-webserver). RPi-spezifische Abschnitte sind entsprechend markiert.

## Bootloader

Aarch64 unterstützt **kein** systemd-boot. GRUB muss explizit aktiviert werden — Profile defaulten auf systemd-boot:

```nix
boot.loader = {
  systemd-boot.enable = false;
  grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  efi.canTouchEfiVariables = true;
};
```

## Cross-Compile

Beim Bauen auf `x86_64` für `aarch64` muss die System-Architektur angegeben werden. Die Flake-Konfiguration enthält dies bereits pro Host (`system = "aarch64-linux"`).

Damit Cross-Compile funktioniert, muss `boot.binfmt.emulatedSystems` auf dem Build-Host gesetzt sein:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

## Firmware

ARM-Boards brauchen oft proprietäre Firmware. In der Host-Config:

```nix
hardware.enableRedistributableFirmware = true;
```

## UART-Boot (Raspberry Pi)

Falls kein Monitor angeschlossen: Serial-Console aktivieren für Boot-Diagnose.

```nix
boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
```

Verbinden mit einem USB-Seriell-Adapter:

```bash
screen /dev/ttyUSB0 115200
```

## Raspberry Pi 5 Besonderheiten

Der RPi5 bootet mit U-Boot + UEFI. Dafür muss das `raspberrypi-firmware`-Paket und das U-Boot-Image installiert sein. Bei einer Neuinstallation per `nixos-anywhere` muss das Zielsystem bereits UEFI-fähig booten (z.B. via RPi-EFI-Image auf SD-Karte).

## Weiterführendes

- Bootloader-Override (roo6): siehe `hosts/roo6/default.nix`
- Bootloader-Override (rpi5-webserver): siehe Arbeitgeber-GitLab-Repo
- Generischer Install-Ablauf: siehe [Neuinstallation](fresh-install.md)
