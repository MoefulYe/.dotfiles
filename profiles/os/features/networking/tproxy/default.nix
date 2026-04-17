{ lib, ... }:
with lib;
{
  # 参考
  # https://wiki.metacubex.one/handbook/
  # https://clash.wiki/
  # https://linux.do/t/topic/163682
  # https://linux.do/t/topic/832271
  # https://wiki.metacubex.one/example/conf/?h=geodata#__tabbed_1_3
  # https://clash-meta.gitbook.io/clash.meta-wiki-older
  # https://www.aloxaf.com/2025/04/how_to_use_geosite/
  # https://evine.win/p/我的家庭网络设计思路开启debian的旁路由之路四
  options.osProfiles.features.tproxy = {
    tproxyBypass = {
      sliceName = mkOption {
        type = types.str;
        default = "system-tproxy_bypass.slice";
      };
      cgroupName = mkOption {
        type = types.str;
        default = "system.slice/system-tproxy_bypass.slice";
      };
      cgroupLevel = mkOption {
        type = types.int;
        default = 2;
      };
    };
    mihomo = {
      user = mkOption {
        type = types.str;
        default = "mihomo";
      };
      dnsPort = mkOption {
        type = types.int;
        default = 7893;
      };
      socks5Port = mkOption {
        type = types.int;
        default = 7894;
      };
      tproxyPort = mkOption {
        type = types.int;
        default = 7895;
      };
      tproxyBypassSocks5Port = mkOption {
        type = types.int;
        default = 7905;
        description = "这个sock5s端口什么都不做仅仅转发请求, 用于实现按需绕过的功能";
      };
      externalController = mkOption {
        type = types.int;
        default = 9090;
      };
      logLevel = mkOption {
        type = types.str;
        default = "error";
      };
      uid = mkOption {
        type = types.int;
        default = 61382;
      };
    };
    nftables = {
      tproxyMark = mkOption {
        type = types.int;
        default = 1;
      };
      outbounds = mkOption {
        type = types.listOf types.str;
      };
      networkdUnitName = mkOption {
        type = types.str;
        default = "50-tproxy";
      };
      # prefixed by /var/lib
      chinaIpListDirname = mkOption {
        type = types.str;
        default = "nftables-china-ips";
      };
      chinaIPListBasename = mkOption {
        type = types.str;
        default = "china-ips.nft";
      };
      chinaIpV4Set = mkOption {
        type = types.str;
        default = "china-ip-list-v4";
      };
      chinaIpV6Set = mkOption {
        type = types.str;
        default = "china-ip-list-v6";
      };
      updateSchedule = mkOption {
        type = types.str;
        default = "*-*-* 04:00:00";
      };
    };
  };
  imports = [
    ./tproxy-bypass-user.nix
    ./sys-fw.nix
    ./mihomo
  ];
}
