{pkgs, ...}: {
  # nano nicht installieren
  programs.nano.enable = false;

  # micro installieren + "nano" auf micro umbiegen
  environment.systemPackages = with pkgs; [
    micro
    (writeShellScriptBin "nano" ''
      echo "nano ist nicht installiert. (Run: nix run nixpkgs#nano)"
      echo "Starte micro... (Beenden: Strg+Q)"
      sleep 3
      exec micro "$@"
    '')
  ];
}
