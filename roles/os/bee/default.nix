{
  inputs,
  paths,
  lib,
  config,
  ...
}:
let
  inherit (paths) osProfiles;
in
{
  options = {
    bee = {
      interfaceMatchName = lib.mkOption {
        type = lib.types.str;
        default = "en*";
        description = "The network interface name pattern to match for bee networking.";
      };
      interfaceConfigFilename = lib.mkOption {
        type = lib.types.str;
        default = "10-en";
        description = "The systemd-networkd network config file name (without .network suffix) for bee networking.";
      };
      address = lib.mkOption {
        type = lib.types.str;
        description = "The static IP address with CIDR notation for the bee networking interface.";
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        description = "The gateway IP address for the bee networking interface.";
      };
      dns = lib.mkOption {
        type = lib.types.str;
        description = "The DNS server IP addresses for the bee networking interface.";
      };
      tapId = lib.mkOption {
        type = lib.types.str;
        description = "The tap interface ID for bee microVM.";
      };
      mac = lib.mkOption {
        type = lib.types.str;
        description = "The MAC address for bee microVM.";
      };
      vcpu = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "The number of vCPUs for bee microVM.";
      };
      mem = lib.mkOption {
        type = lib.types.int;
        default = 2048;
        description = "The amount of memory (in MB) for bee microVM.";
      };
    };
  };
  imports = [
    inputs.microvm.nixosModules.microvm
    inputs.impermanence.nixosModules.impermanence
    "${osProfiles}/common"
    "${osProfiles}/preferences/tiny"
    "${osProfiles}/utils/tiny"
  ];
  config = {
    services.openssh.settings.PermitRootLogin = "prohibit-password";
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvnf1TDq7kpCwOMFK0Vn6x7zjMEiGGIVhknGN+kC3n0 ashenye@desk00-u265kf-lan"
    ];
    systemd.network.networks."${config.bee.interfaceConfigFilename}" = {
      matchConfig.Name = config.bee.interfaceMatchName;
      networkConfig = {
        Address = [ config.bee.address ];
        Gateway = [ config.bee.gateway ];
        DNS = [ config.bee.dns ];
      };
    };
    fileSystems."/var".options = [
      "defaults"
      "noatime"
      "commit=60"
    ];
    virtiofsd.extraArgs = [
      "--cache=always"
      "--writeback" # 会提升性能，但可能缓存一致性较差, 只共享只读目录无所谓了
    ];
    volumes = [
      {
        mountPoint = "/var";
        image = "/dev/vg_pool/vm0";
        size = 1024 * 64;
        fsType = "ext4";
      }
    ];
    shares = [
      {
        proto = "virtiofs";
        tag = "ro-store";
        # a host's /nix/store will be picked up so that no
        # squashfs/erofs will be built for it.
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      # 根目录配置
    ];
    interfaces = [
      {
        type = "tap";
        id = config.bee.tapId;
        mac = config.bee.mac;
      }
    ];
    hypervisor = "cloud-hypervisor";
    socket = "control.socket";
    mem = config.bee.mem;
    vcpu = config.bee.vcpu;
    services.fstrim.enable = true;
  };
}
