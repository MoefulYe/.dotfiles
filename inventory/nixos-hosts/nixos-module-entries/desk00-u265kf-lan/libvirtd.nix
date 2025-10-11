{ pkgs, ... }: { 
  users.groups.libvirt = {};
  users.groups.kvm = {};
  virtualisation.libvirtd = {
    # enable = true;
    enable = false;
    extraConfig = ''
      unix_sock_group = "libvirt"
    '';
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      # ovmf = {
      #   enable = true;
      #   packages = [(pkgs.OVMF.override {
      #     secureBoot = true;
      #     tpmSupport = true;
      #   }).fd];
      # };
    };
  };
}
