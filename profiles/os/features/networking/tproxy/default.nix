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
    tproxyBypassUser = {
      name = mkOption {
        type = types.str;
        default = "tproxy-bypass";
      };
      uid = mkOption {
        type = types.int;
        default = 61382;
      };
    };
    mihomo = {
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
      socks5PortForSmartDnsResolving = mkOption {
        type = types.int;
        default = 7896;
      };
      externalController = mkOption {
        type = types.int;
        default = 9090;
      };
      logLevel = mkOption {
        type = types.str;
        default = "warning";
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
    smartdns = {
      enableAntiAD = mkEnableOption "enable anti ad";
      antiAdUpdateSchedule = mkOption {
        type = types.str;
        default = "*-*-* 04:00:00";
      };
      extraSettings = mkOption {
        type = types.str;
        default = "";
      };
      # 在代理未运行的情况下也是默认的系统dns
      domesticDnsPort = mkOption {
        type = types.int;
        default = 53;
      };
      foreignDnsPort = mkOption {
        type = types.int;
        default = 7898;
      };
    };
    extraProxies = {
      zju-connect = {
        enable = mkEnableOption "enable zju connect proxy";
        socks5Port = mkOption {
          type = types.int;
          default = 7899;
        };
      };
    };
  };
  imports = [
    ./tproxy-bypass-user.nix
    ./sys-fw.nix
    ./smartdns
    ./mihomo
    ./extra-proxies
  ];
}
