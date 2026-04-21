{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-profiles.nixosProfiles.embedded
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
  ];

  # Kein System-User — embedded Gerät läuft als root
  custom.users.main.create = false;

  # RPi5 generational bootloader
  boot.loader.raspberry-pi.bootloader = "kernel";

  # Override: embedded Profil setzt systemd-boot, RPi braucht eigenen Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  # WiFi Access Point
  custom.networking.access-point = {
    enable = true;
    interface = "wlan0";
    ssid = "eis-rpi-webserver";
    password = "CHANGE_ME";
    channel = 7;
    countryCode = "DE";
    staticAddress = "192.168.4.1";
    staticPrefixLength = 24;
  };

  # DHCP/DNS für AP-Clients
  custom.networking.dnsmasq = {
    enable = true;
    interface = "wlan0";
    subnet = "192.168.4.0";
    subnetMask = "255.255.255.0";
    leaseRangeStart = "192.168.4.10";
    leaseRangeEnd = "192.168.4.100";
    leaseTime = "24h";
    upstreamDNS = ["8.8.8.8" "8.8.4.4"];
  };

  # PHP-nginx Webserver
  custom.services.php-nginx = {
    enable = true;
    domain = "rpi5-webserver";
  };

  # Firewall: php-nginx + openssh auf AP-Interface
  custom.firewall.exposedByZone = {
    ap = ["php-nginx" "openssh"];
  };
  custom.firewall.zoneInterfaces = {
    ap = ["wlan0"];
  };

  # Home-Manager für root
  custom.home-manager.users.root = [
    inputs.hm-chammy.homeManagerModules.core
  ];

  networking.hostName = "rpi5-webserver";
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.11";
}
