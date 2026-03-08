{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];
  boot.kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest;
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

  # ZFS config
  # boot.supportedFilesystems.zfs = true;
  # boot.zfs.package = pkgs.cachyosKernels.zfs-cachyos.override {
  # kernel = config.boot.kernelPackages.kernel;
  #};

  # ... your other configs
}
