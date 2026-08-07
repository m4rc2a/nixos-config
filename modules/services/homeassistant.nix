{
  lib,
  config,
  ...
}: {
  services.home-assistant = {
    enable = true;
    openFirewall = false;

    configWritable = true;
    configDir = "/var/lib/hass";

    config = {
      http.server_port = lib.mkDefault 8123;
      http.trusted_proxies = ["127.0.0.1" "::1"];
      http.use_x_forwarded_for = true;
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
