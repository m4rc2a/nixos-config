{
  lib,
  config,
  ...
}: {
  config = {
    services.gitlab = {
      enable = true;

      host = lib.mkDefault "git.roo6.lan";
      port = lib.mkDefault 8080;

      extraConfig = {
        gitlab = {
          email_from = lib.mkDefault "gitlab@git.roo6.lan";
          email_display_name = "Fischerwerft GitLab";
          email_reply_to = lib.mkDefault "noreply@git.roo6.lan";
        };
      };
    };

    custom.services.ports.gitlab.tcp = [8080];
    custom.services.ports.gitlab.udp = [];
  };
}
