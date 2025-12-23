{
  services.fstrim.enable = true;
  services.fstrim.interval = "weekly"; # 每周整理一次 SSD/eMMC 空间
  powerManagement.cpuFreqGovernor = "performance";
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # J4105 支持 AES-NI 和现代指令集，zstd 压缩比高且速度快
    memoryPercent = 75; # 允许 ZRAM 占用 75% 的 RAM 大小（逻辑大小，非物理占用）
    priority = 100; # 优先级设为最高，确保先用 ZRAM，最后才用物理 Swap（如果有的话）
  };
  boot.kernel.sysctl = {
    # 1. 激进使用 Swap (ZRAM)
    # 默认是 60。设为 150-180 (新内核上限是 200) 告诉内核：
    # "只要内存有点压力，就立刻把不活跃的程序数据压缩进 ZRAM，不要随便丢弃文件缓存。"
    # 路由器的网络吞吐非常依赖文件系统缓存（Buffer），所以我们要保护缓存。
    "vm.swappiness" = 130;

    # 2. 优化 ZRAM 的页面读取
    # 默认是 3 (一次读 8页)。对于物理磁盘这是为了减少寻道，但 ZRAM 是内存，没有寻道成本。
    # 设为 0 禁止预读，降低延迟（Latency），取一页就是一页。
    "vm.page-cluster" = 0;

    # 3. 内存水位控制 (防卡顿)
    # 增加最小空闲内存的保留比例。防止突发流量瞬间耗尽内存导致系统卡死（Live lock）。
    # 125 = 1.25% 的 RAM 始终保留为“紧急备用”。
    "vm.watermark_scale_factor" = 180;
    # 内核网络栈微调
    # Enable IP Forwarding (Essential for a router)
    # "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    # TCP BBR Congestion Control (Better throughput for Tailscale/Proxy)
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    # Increase TCP buffer sizes for high-speed connections (Gigabit+)
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 4194304;
    "net.ipv4.tcp_rmem" = "4096 87380 4194304";
    "net.ipv4.tcp_wmem" = "4096 16384 4194304";
    # ARP tweaks for larger LANs (Prevent ARP cache thrashing)
    "net.ipv4.neigh.default.gc_thresh1" = 1024;
    "net.ipv4.neigh.default.gc_thresh2" = 2048;
    "net.ipv4.neigh.default.gc_thresh3" = 4096;
  };
  boot.kernelModules = [
    "tcp_bbr"
    "nf_conntrack"
    "nf_conntrack_netlink"
  ];
  nix.settings.max-jobs = 1;
}
