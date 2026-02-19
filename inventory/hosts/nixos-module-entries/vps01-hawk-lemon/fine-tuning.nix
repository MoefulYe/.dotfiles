{ lib, ... }:
{
  # 针对 1C1G 低配 VPS 的优化配置

  # 启用 GRUB 引导器（适用于大多数 VPS）
  osProfiles.common.bootloader = "grub";

  # 时区配置（洛杉矶）
  time.timeZone = lib.mkForce "America/Los_Angeles";

  # NTP 服务器配置（使用美国西海岸的 NTP 服务器）
  services.timesyncd.servers = lib.mkForce [
    "time.cloudflare.com"
    "time.google.com"
    "time.nist.gov"
  ];

  # 启用 zramSwap 以提高内存利用率
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # 高压缩比且速度快
    memoryPercent = 100; # 1G 内存较小，允许 ZRAM 占用 100% RAM 大小（逻辑大小）
    priority = 100; # 最高优先级，优先使用 ZRAM
  };

  boot.kernel.sysctl = {
    # 内存管理优化
    # 对于 1G 内存的 VPS，适度使用 swap 以避免 OOM
    "vm.swappiness" = 60; # 默认值，平衡内存和 swap 使用

    # ZRAM 优化：禁止预读以降低延迟
    "vm.page-cluster" = 0;

    # 保留一定的空闲内存防止突发流量导致 OOM
    "vm.watermark_scale_factor" = 150;

    # 网络优化（适用于 API 中转服务）
    # TCP BBR 拥塞控制算法，提升网络吞吐
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # 增加 TCP 缓冲区大小以支持高并发连接
    "net.core.rmem_max" = 2097152; # 2MB（1G 内存下适度调整）
    "net.core.wmem_max" = 2097152;
    "net.ipv4.tcp_rmem" = "4096 87380 2097152";
    "net.ipv4.tcp_wmem" = "4096 16384 2097152";

    # 增加最大连接跟踪数（API 中转需要处理大量连接）
    "net.netfilter.nf_conntrack_max" = 65536;

    # 加快 TIME_WAIT 连接回收
    "net.ipv4.tcp_fin_timeout" = 30;
    "net.ipv4.tcp_tw_reuse" = 1;
  };

  boot.kernelModules = [
    "tcp_bbr"
    "nf_conntrack"
  ];

  # 禁用自动 Nix store 优化以节省 CPU 和 I/O
  nix.optimise.automatic = false;

  # 限制 Nix 构建时的并行任务数（1C CPU）
  nix.settings.max-jobs = 1;
  nix.settings.cores = 1;
}
