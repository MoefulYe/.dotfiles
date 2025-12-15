{
  paths,
  config,
  lib,
  ...
}:
{
  sops.secrets = {
    NIX_REMOTE_BUILDER_PRIVKEY = {
      mode = "0400";
      sopsFile = "${paths.secrets}/app-secrets.yaml";
    };
  };
  # You can see the resulting builder-strings of this NixOS-configuration with "cat /etc/nix/machines".
  # These builder-strings are used by the Nix terminal tool, e.g.
  # when calling "nix build ...".
  nix.buildMachines = [
    {
      # Will be used to call "ssh builder" to connect to the builder machine.
      # The details of the connection (user, port, url etc.)
      # are taken from your "~/.ssh/config" file.
      hostName = "remote-builder";
      # CPU architecture of the builder, and the operating system it runs.
      # Replace the line by the architecture of your builder, e.g.
      # - Normal Intel/AMD CPUs use "x86_64-linux"
      # - Raspberry Pi 4 and 5 use  "aarch64-linux"
      # - M1, M2, M3 ARM Macs use   "aarch64-darwin"
      # - Newer RISCV computers use "riscv64-linux"
      # See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/lib/systems/flake-systems.nix
      # If your builder supports multiple architectures
      # (e.g. search for "binfmt" for emulation),
      # you can list them all, e.g. replace with
      # systems = ["x86_64-linux" "aarch64-linux" "riscv64-linux"];
      system = "x86_64-linux";
      # Nix custom ssh-variant that avoids lots of "trusted-users" settings pain
      protocol = "ssh-ng";
      # default is 1 but may keep the builder idle in between builds
      maxJobs = 20;
      # how fast is the builder compared to your local machine
      speedFactor = 4;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];
  # required, otherwise remote buildMachines above aren't used
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.settings = {
    builders-use-substitutes = true;
  };
  programs.ssh.extraConfig = ''
    Host remote-builder
      User remote-builder
      HostName builder.nix.void
      IdentityFile ${config.sops.secrets.NIX_REMOTE_BUILDER_PRIVKEY.path}
      Port 2222
  '';
  # set local's max-job to 0 to force remote building(disable local building)
  nix.settings.max-jobs = lib.mkDefault 0;
}
