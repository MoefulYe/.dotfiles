# NixOS Onboarding Checklist (Multi-stage)

This repository wires NixOS hosts through `inventory/hosts`, `roles/os`, and host-local configs under `inventory/hosts/nixos/<host-id>`.

Use `infra/onboard/template/` as the **minimum remote-connectable** starter set.

## Stage 0: Minimal inventory + template (for remote install)

Goal: prepare the smallest set of files to let `nixos-anywhere` install a bootable NixOS with SSH access.

### 0.0 Verify target connectivity
- [ ] Ensure the target is reachable: `ssh -o BatchMode=yes -o ConnectTimeout=10 root@<ip>`
- [ ] If the host uses a non-standard SSH port, add `-p <port>`.

### 0.1 Pick identity
- [ ] `host-id`: lower-kebab-case (used in flake as `.#<host-id>`)

### 0.2 Create minimal host directory
Copy the template directory and edit it:

```bash
cp -r infra/onboard/template inventory/hosts/nixos/<host-id>
```

Edit the following files in `inventory/hosts/nixos/<host-id>/`:
- `configuration.nix`: imports, hostname, users, SSH, etc.
- `networking.nix`: pick ONE option (DHCP / networkd DHCP / static)
- `disko.nix`: disk layout (required for nix-anywhere + disko)

### 0.3 Register host in inventory
Add a new entry to `inventory/hosts/default.nix`:

```nix
  <host-id> = {
    system = "x86_64-linux";
    nixosConfig = ./nixos/<host-id>;
  };
```

### 0.4 Minimal remote-access checks
- `configuration.nix` must enable `services.openssh.enable = true;`
- Ensure your SSH key is authorized for root or a bootstrap user.

## Stage 1: Remote install (nixos-anywhere)

Run on your local machine from this repo:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./inventory/hosts/nixos/<host-id>/hardware-configuration.nix \
  --target-host root@<ip> \
  --flake .#<host-id>
```

Notes:
- Replace `<ip>` and `<host-id>`.
- Ensure `disko.nix` is referenced by your host configuration if you use disko.

## Stage 2: NixOS system config
- [ ] Add `role` to `inventory/hosts/default.nix` when you are ready to apply a profile set.
- [ ] Add primary users (if needed) in `inventory/hosts/nixos/<host-id>/users.nix`.
- [ ] Adjust `inventory/hosts/nixos/<host-id>/configuration.nix` (services, users, bootloader).
- [ ] Adjust `networking.nix` if the provider requires static config.
- [ ] Enable host-side SOPS (via role or by importing `profiles/os/common/nix-settings/sops.nix`).
- [ ] Generate host age key locally: `just gen-age-key ~/.config/sops/age/<host-id>.txt`.
- [ ] Push key to host: `scp ~/.config/sops/age/<host-id>.txt root@<ip>:/var/lib/sops-nix/keys.txt`.
- [ ] Fix permissions on host: `ssh root@<ip> 'chmod 0400 /var/lib/sops-nix/keys.txt'`.
- [ ] Add the host age key to `.sops.yaml` under the right groups.
- [ ] Rekey secrets with `just update-sops` (per file).
- [ ] Apply: `sudo nixos-rebuild switch --flake .#<host-id>`.

### Stage 2 key options (VPS-focused)
These are defined in profiles and are commonly adjusted for VPS installs:

- `profiles/os/common/services/openssh.nix`: `services.openssh.settings.PermitRootLogin` (default `no`), `services.openssh.settings.PasswordAuthentication` (default `false`), `services.openssh.ports` (default `[ 2222 ]`).
- `profiles/os/common/services/firewall.nix`: `networking.nftables.enable` and `networking.firewall.enable` (both default `true`); add host-specific `networking.firewall.allowedTCPPorts` / `allowedUDPPorts` as needed.
- `profiles/os/common/services/networkd.nix`: `networking.useNetworkd = true; systemd.network.enable = true;` (define `systemd.network.networks.<name>` in `inventory/hosts/nixos/<host-id>/networking.nix` for static IPs).
- `profiles/os/common/services/resolved.nix`: `services.resolved.enable` (default `true`).
- `profiles/os/common/services/timesyncd.nix`: `services.timesyncd.servers` (default CN NTP servers).
- `profiles/os/common/base-system/bootloader.nix`: `osProfiles.common.bootloader` (`systemd-boot` / `grub` / `none`).
- `profiles/os/common/base-system/i18n.nix`: set `time.timeZone` explicitly for VPS; common values: `Asia/Shanghai`, `Asia/Hong_Kong`, `Asia/Singapore`, `Asia/Tokyo`, `Asia/Seoul`, `Asia/Kolkata`, `Europe/London`, `Europe/Berlin`, `Europe/Amsterdam`, `Europe/Paris`, `Europe/Moscow`, `America/New_York`, `America/Chicago`, `America/Denver`, `America/Los_Angeles`, `America/Toronto`, `Australia/Sydney`.
- `profiles/os/common/nix-settings/nix.nix`: `nix.optimise.automatic`, `nix.channel.enable`, `nix.settings.trusted-users`, `system.stateVersion`.
- `profiles/shared/nix-settings/nix-conf-settings.nix`: `nix.settings.experimental-features`, `nix.settings.substituters`, `nix.settings.trusted-public-keys`.
- `profiles/os/nix/garbage-collector.nix`: `nix.gc` weekly, `--delete-older-than 7d`.
- `profiles/os/common/nix-settings/sops.nix`: `sops.age.generateKey = true` and `sops.age.keyFile = "/var/lib/sops-nix/keys.txt"`.

Time zone lookup helpers:
- `timedatectl list-timezones | rg -i '<city|region>'`
- `timedatectl list-timezones | rg -i '<country|continent>'`

## Stage 3: Home Manager
- [ ] Add user entry to `inventory/users/default.nix`.
- [ ] Create `inventory/users/home-manager/<host-id>.nix` if needed.
- [ ] Add SSH config stub at `inventory/users/ssh-configs/<host-id>.nix`.
- [ ] Apply: `just deploy-home` (or `home-manager switch --flake ".#<user>@<host>" -b bak`).

## Stage 4: Validation
- [ ] Validate services, networking, and SSH access.
- [ ] Optional: `nix flake check`.

## Notes
- This repo often uses SSH port `2222`; adjust if your host differs.
- Keep host/user-specific logic in `inventory/` and wire it through roles/profiles.
