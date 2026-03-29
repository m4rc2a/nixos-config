{pkgs, ...}: {
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      max-jobs = "auto";
      cores = 0; # alle CPU-Threads
    };
  };

  # dinge bauen mit nix
  programs.ccache.enable = true;
  environment.variables.NIX_LDFLAGS = "-fuse-ld=mold";
  environment.systemPackages = with pkgs; [mold];
}
