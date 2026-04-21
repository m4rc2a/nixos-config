{
  pkgs,
  self,
  ...
}: let
  prodToplevel = self.nixosConfigurations.rpi5-webserver.config.system.build.toplevel;
in {
  boot.loader.raspberry-pi.bootloader = "kernel";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    settings.PasswordAuthentication = true;
  };

  environment.systemPackages = with pkgs; [cloud-utils e2fsprogs util-linux nix];

  systemd.services.autonomous-bootstrap = {
    description = "One-shot: expand SD, switch to prod";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    path = with pkgs; [cloud-utils e2fsprogs util-linux nix];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail

      MARKER=/var/lib/autonomous-bootstrap/done
      mkdir -p "$(dirname "$MARKER")"
      [ -f "$MARKER" ] && exit 0

      # Root-Partition finden und vergrößern
      ROOT_SRC="$(findmnt -n -o SOURCE /)"
      ROOT_DEV="$(readlink -f "$ROOT_SRC" 2>/dev/null || echo "$ROOT_SRC")"
      [ -b "$ROOT_DEV" ] || { echo "ERROR: $ROOT_DEV not a block device"; lsblk -f; exit 1; }

      PKNAME="$(lsblk -no PKNAME "$ROOT_DEV" | head -n1)"
      PART_NUM="$(lsblk -no PARTNUM "$ROOT_DEV" | head -n1)"
      [ -n "$PKNAME" ] && [ -n "$PART_NUM" ] || { echo "ERROR: Cannot determine disk/part"; lsblk; exit 1; }

      echo "Growing partition $PART_NUM on /dev/$PKNAME..."
      growpart "/dev/$PKNAME" "$PART_NUM" || true
      resize2fs "$ROOT_DEV"

      # Auf Produktiv-Konfiguration umschalten
      echo "Switching to production config..."
      nix-env -p /nix/var/nix/profiles/system --set "${prodToplevel}"
      /nix/var/nix/profiles/system/bin/switch-to-configuration switch

      touch "$MARKER"
      echo "Bootstrap done. Rebooting..."
      systemctl reboot
    '';
  };
}
