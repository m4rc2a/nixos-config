{
  lib,
  config,
  ...
}: {
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    configWritable = true;
    configDir = "/var/lib/hass";

    config = {
      http.server_port = lib.mkDefault 8123;
      homeassistant = {
        name = config.networking.hostName;
        time_zone = "Europe/Berlin";
        temperature_unit = "C";
        unit_system = "metric";
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
}
