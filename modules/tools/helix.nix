{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      helix
      alejandra
      nil
    ];

    etc = {
      "helix/config.toml".text = ''
        theme = "ao"

        [editor]
        line-number = "relative"
        true-color = true

        [editor.cursor-shape]
        insert = "bar"
        normal = "block"
        select = "underline"

        [keys.normal]
        A-q = ":q!"
        A-z = ":wq"
      '';

      "helix/languages.toml".text = ''
        [[language]]
        auto-format = true
        language-servers = ["nil"]
        name = "nix"

        [language.formatter]
        command = "alejandra"
      '';
    };
  };
}
