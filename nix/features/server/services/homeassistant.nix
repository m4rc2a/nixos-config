{
  lib,
  config,
  hostName,
  ...
}: let
  cfg = config.custom.services.homeassistant;
in {
  options.custom.services.homeassistant = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 8123;
      description = "Home Assistant HTTP listen port.";
    };
  };

  config = {
    services.home-assistant = {
      enable = true;
      openFirewall = false;

      # Damit HA über App/UI weiter schreiben darf
      configWritable = true;
      configDir = "/var/lib/hass";

      config = {
        http.server_port = cfg.port;
        homeassistant = {
          name = hostName;
          time_zone = "Europe/Berlin";
          temperature_unit = "C";
          unit_system = "metric";
          longitude = 10.517174;
          latitude = 52.155262;
        };
      };

      extraComponents = [
        "default_config"
        "esphome"
        "hue"
        "matter"
        "shopping_list"
        "workday"
        "systemmonitor"
        "luci"
        "icloud"
        "itunes"
        "apple_tv"
        "homekit"
        "homekit_controller"
      ];
    };

    custom.services.ports.homeassistant.tcp = [cfg.port];
    custom.services.ports.homeassistant.udp = [];
  };
}
