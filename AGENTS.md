# AGENTS.md

## Key Commands

```bash
nixos-rebuild build --flake .#<hostname>       # dry-run build
nix flake check                                 # validate flake
nix flake show                                  # list nixosConfigurations
```

Remote deploy (deploy-rs):
```bash
nix run .#deploy-rs -- .#<node>                # deploy a node (all its profiles)
nix run .#deploy-rs -- .#<node>.<profile>      # deploy a single profile
nix run .#deploy-rs -- --groups <group>        # deploy by group tag (servers/laptops/desktops/all)
nix run .#deploy-rs -- --dry-run .             # dry-run everything
```

Fresh install:
```bash
nix run github:numtide/nixos-anywhere -- --flake .#<hostname> root@<host>
```

## Architecture

Two-repo split — **this repo is node configs only**:
- `hm-config` (Codeberg, flake input) — shared home-manager modules/profiles (has its own `hosts/` + `profiles/` dirs; those are the OTHER repo, not renamed).
- **This repo** — hardware configs, system assignment, machine-specific overrides, local `nodes/` + `systems/` + `modules/`.

### Directory naming (avoid confusion with deploy-rs)
- **`nodes/`** = one dir per machine (`roo6`, `marc-laptop`, `marc-desktop`). These are the deploy-rs "nodes".
- **`systems/`** = local NixOS "system" bundles (`server`, `laptop`, `desktop`, `gaming-pc`, `wsl`). Do NOT call deploy-rs's inner deployables (its `system`/`home-marc`/`home-root`) "profiles" here — deploy-rs uses that word for them.
- **`systems/wsl.nix`** is a **template** for future WSL installs — it is NOT a deployed node/host and is not referenced by any `flake.nix`/`nodes/*`. Don't deploy it or register it.

No Snowfall Lib. All module imports are explicit.

## Hosts

| Host | System | Profile | Notes |
|------|--------|---------|-------|
| `roo6` | `aarch64-linux` | server | Radxa Orion O6. User `marc` with SSH key. Uses systemd-boot (aarch64 supported since systemd v253). `network-interfaces.nix` for MAC-based interface naming. Deployed as `root` via SSH reverse tunnel (see Gotchas). Reverse proxy: **Caddy** (`git.zander.cloud`→Forgejo:3000, `hass.zander.cloud`→Home Assistant:8123). |
| `marc-laptop` | `x86_64-linux` | laptop | Heads BIOS — boots via kexec, no traditional bootloader. LUKS-encrypted root. Uses ext4 `/boot` (not vfat/EFI). |
| `marc-desktop` | `x86_64-linux` | gaming-pc | Desktop-PC. Uses systemd-boot. Home-manager via `hm-config` `hosts/desktop-pc.nix`. |

## Custom Options

All custom options use `custom.` prefix. Key ones an agent will encounter:

- `custom.users.main.create` / `custom.users.main.name` / `custom.users.main.groups` — user creation

- `custom.home-manager.users.<name>` — list of hm-config modules to apply per user
- `custom.security.apparmor.enable` / `.mode`
- `custom.tools.yazi.flavors` — attrset of flake inputs for yazi theme flavors

## Conventions

- Home-manager is integrated via NixOS module (`inputs.home-manager.nixosModules.home-manager`), not standalone.
- Home-manager modules come from `hm-config` flake input, not the `./home-manager` submodule (removed in recent refactor).
- Each host's `default.nix` imports the profile, disko, home-manager, and local hardware files.
- `disk-config.nix` uses disko; device paths must be verified on target hardware (`lsblk -f`).
- Firewall is configured via `services.<name>.openFirewall = true` or `networking.firewall.allowedTCPPorts` directly in service modules.

## Gotchas

- **Bootloader (roo6)**: Uses systemd-boot — aarch64 supports it since systemd v253. Do NOT add GRUB for aarch64 hosts.
- **Heads BIOS (marc-laptop)**: No EFI boot. `/boot` is ext4, kernel/initrd/cmdline are exported to `/boot/kexec/` via activation scripts. Don't add bootloader config to this host.
- **`custom.users.main.create = true`** on roo6 means user `marc` is created with SSH key. Home-manager runs for both `marc` and `root`.
- **No submodule anymore**: The `./home-manager` git submodule referenced in older docs has been replaced by the `hm-config` flake input.
- **Deploy-rs is in `flake.nix`**: `deploy.nodes` defines nodes/profiles/groups. Group filtering is via `deploy --groups <tag>`, NOT `.#<group>` fragments. Deploy profile order for roo6: `system` → `home-root` → `home-marc` (all as `sshUser = "root"`).
- **roo6 deploys as `root` over a reverse SSH tunnel**: node `roo6` sets `hostname = "home"` (a `~/.ssh/config` alias → `127.0.0.1:2443` via `ProxyJump shelog`), `sshUser = "root"`, `interactiveSudo = false`. Root gets the same ed25519 key in `nodes/roo6/default.nix` and `PermitRootLogin = "prohibit-password"` is `mkForce`d. Don't use deploy-rs `sudo` here.
- **REVISED — Caddy reverse proxy (roo6)**: `modules/services/caddy.nix` == now the public entrypoint, serving `git.zander.cloud`→`127.0.0.1:3000` and `hass.zander.cloud`→`127.0.0.1:8123` with ports 80/443 open. Old `systems/server.nix` imported nginx + `modules/services/nginx.nix` was deleted. Home Assistant sets `trusted_proxies = ["127.0.0.1" "::1"]`, `use_x_forwarded_for = true`, `openFirewall = false`.
- **Standalone hmConfigurations in flake.nix** need `home.username`/`home.homeDirectory`/`allowUnfree`/sharedModules explicitly, mirroring what the NixOS host sets.
- **home-manager NixOS module does NOT forward `nixosSystem.specialArgs` to per-user HM modules**: set `home-manager.extraSpecialArgs = { nixos_secrets = inputs.nixos-secrets; }` when a user's HM config references `nixos_secrets` (e.g. `marc-desktop`).
- **Forgejo (roo6)**: Replaced GitLab (2026-08). Serves `git.zander.cloud` via **Caddy** → `127.0.0.1:3000`, sqlite3 DB, Forgejo's own SSH on port **2222** (not 22). `SECRET_KEY` comes from sops secret `forgejo_session_key`.
- **Forgejo module manages its own secrets**: `services.forgejo.secrets."security"."SECRET_KEY"` etc. are set hard by the module (auto-generated under `customDir/conf`). To inject a sops secret you MUST use `lib.mkForce`, else you get a "conflicting definition values" error.
- **Dead module trap**: `gitlab.nix` existed in `modules/services/` but was imported NOWHERE (only referenced by `nginx.nix` via `config.services.gitlab.port`). Before assuming a service is active, grep for the import — leftover modules can rot silently.
- **`nix flake check` / deploy-rs pre-checks build ALL hosts** (incl. big desktop x86_64 configs) and take a long time. Use deploy-rs `--skip-checks` for a fast dry-run; the flag is `--dry-activate` (there is NO `--dry-run`). `nixos-rebuild build --flake .#roo6` is the fast target-specific check.
- **`nixos-secrets` repo has NO git remote yet** — do not try to push it; user plans to deploy it to roo6 later.
- **`nix flake check`/`flake update` need all referenced files git-tracked** — untracked new files (e.g. `modules/services/forgejo.nix`) abort the build with "Path ... is not tracked by Git". `git add` before building.
- **headless server home-manager fails on `dconfSettings`**: On roo6 there is no D-Bus session bus, so HM activation aborts in the `Aktiviere dconfSettings` step (`GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown`). The trigger is `stylix.autoEnable` turning on GUI targets that write `dconf.settings` (gtk, qt, gnome, **eog** → `org/gnome/eog`, **gnome-text-editor** → `org/gnome/TextEditor`) even when the app is NOT installed. Fix lives in hm-config `platforms/server.nix`: `stylix.autoEnable = lib.mkForce false` + `targets.gtk/qt/gnome.enable = lib.mkForce false`.
- **`stylix.autoEnable` is a global default switch, NOT install-based detection**: every target's `enable` defaults to `config.stylix.autoEnable && <target autoEnable>` (see stylix `target.nix`). So with `autoEnable` unset a headless box turns on eog/gnome-text-editor (which write dconf) even though they're not installed. To disable a target for real you MUST use `lib.mkForce false` (beats the defaults), because explicitly-`true` targets (e.g. `qt` in hm-config `modules/stylix.nix`) survive an `autoEnable=false` unless overridden.
- **Check HM `dconf.settings` before deploying a headless host**: `nix eval .#nixosConfigurations.roo6.config.home-manager.users.marc.dconf.settings` must be `{ }`. Both the NixOS-integrated users and the standalone `hmConfigurations` ("roo6.marc"/"roo6.root") import `platforms/server.nix`, so the fix applies to both paths.
- **hm-config is fetched as a Git input from `codeberg.org:m4rc2a/home-manager`** — changes there require `git commit && git push`, then `nix flake update hm-config` (updates flake.lock; re-commit it), then rebuild. Editing hm-config alone is not enough; the lockfile pins the old rev.
