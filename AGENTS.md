# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` is the entry point for NixOS, Darwin, and Home Manager outputs.
- The NixOS/Home Manager modules are organized as three layers:
  - `modules/{os,hm}` expose configuration for custom modules for NixOS/Home Manager
  - `profiles/{os,hm}` contains specific configuration for NixOS/Home Manager, `profiles/shared` contains configuration shared between NixOS and Home Manager
  - `roles/{os,hm}` organize NixOS/Home Manager profiles into composition
  - `quirks/{os,hm}` contains workaroud configuration for NixOS/Home Manager
- `packages/` and `overlays/` define custom Nix packages and overlays consumed by the flake.
- `inventory/` stores host/user inventory data; `infra/` contains deployment helpers; `helpers/` holds reusable Nix utilities.
- `secrets/` stores SOPS-encrypted material; `docs/` and `trash/` hold notes and archived items.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation; keep attribute sets readable and grouped by purpose.
- Prefer lower-kebab-case for module filenames (e.g., `profiles/os/base.nix`).
- Keep host/user-specific logic in `inventory/` and wire it through roles/profiles.
- Run `nix fmt .` before committing Nix changes.

## Testing Guidelines
- There is no dedicated test suite. Validate changes by evaluating/building:
  - `nix flake check` for flake evaluation.
  - `just deploy-nixos` / `just deploy-home` on a target host or VM.
- For package updates, use `nix build .#packages.<system>.<name>` to verify builds.

## Nix CLI
- Any command that uses the Nix CLI (`nix build`, `nix develop`, `nix shell`, `nix run`, `nix flake`, etc.) must request escalated permissions from the user before execution.
- Reason: Nix commands in this environment may need to write outside the workspace (for example under the shared Nix store / worktree metadata / cache paths), and sandboxed execution can fail with misleading read-only or cache permission errors.
- When asking for escalation, explain briefly that the goal is to avoid sandbox-related cache or store write failures during Nix operations.
