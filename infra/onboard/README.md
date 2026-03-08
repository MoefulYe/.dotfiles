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
- [ ] Apply: `sudo nixos-rebuild switch --flake .#<host-id>`.

## Stage 3: Home Manager
- [ ] Add user entry to `inventory/users/default.nix`.
- [ ] Create `inventory/users/home-manager/<host-id>.nix` if needed.
- [ ] Add SSH config stub at `inventory/users/ssh-configs/<host-id>.nix`.
- [ ] Apply: `just deploy-home` (or `home-manager switch --flake ".#<user>@<host>" -b bak`).

## Stage 4: SOPS + Validation
- [ ] Fetch the host SOPS key with `just get-host-age-key`.
- [ ] Add the host key to `.sops.yaml` under the right groups.
- [ ] Rekey secrets with `just update-sops`.
- [ ] Validate services, networking, and SSH access.
- [ ] Optional: `nix flake check`.

## Notes
- This repo often uses SSH port `2222`; adjust if your host differs.
- Keep host/user-specific logic in `inventory/` and wire it through roles/profiles.
