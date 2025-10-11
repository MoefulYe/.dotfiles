{ pkgs, ... }: { 
  users.groups.libvirt = {};
  users.groups.kvm = {};
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = ''
      unix_sock_group = "libvirt"
    '';
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
}
