{...}: {
  time.timeZone = "Europe/Berlin";

  networking.timeServers = ["pool.ntp.org" "ptbtime1.ptb.de"];

  services.timesyncd.enable = false;
  services.chrony.enable = true;
}
