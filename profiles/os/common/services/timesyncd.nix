{ lib, ... }:
{
  services.timesyncd = {
    enable = lib.mkDefault true;
    servers = [
      "ntp.aliyun.com"
      "ntp.tencent.com"
      "ntp.ntsc.ac.cn"
    ];
  };
}
