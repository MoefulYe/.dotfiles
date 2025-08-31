{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.systemProfiles.features = {
    mihomo = {
      enable = mkEnableOption "Enable mihomo";
      enableWebUI = mkEnableOption "Enable mihomo webUI";
    };
    openssh = {
      enable = mkEnableOption "Enable OpenSSH server";
      PasswordAuthentication = mkEnableOption "enable password authentication";
    };
    enableAutoGC = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic garbage collection for Nix.";
    };
    # 默认启用
    timesyncd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NTP (Network Time Protocol) for time synchronization.";
      };
      servers = mkOption {
        type = types.listOf types.str;
        default = [
          "ntp.aliyun.com"
          "ntp.tencent.com"
          "ntp.ntsc.ac.cn"
        ];
        description = "List of NTP servers to use for time synchronization.";
      };
    };
    virtualisation = {
      podman = {
        enable = mkEnableOption "Enable Podman for container management";
      };
    };
  };
}
