{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.zju-connect;
in
{
  options.services.zju-connect = {
    configFile = lib.mkOption {
      type = lib.types.path;
      description = "config file for ZJU Connect";
    };
    user = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = {
    systemd.services.zju-connect = {
      enable = true;
      description = "ZJU Connect VPN Client";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.my-pkgs.zju-connect}/bin/zju-connect -config ${cfg.configFile}";
        Restart = "on-failure";
        RestartSec = "5s";
        User = cfg.user;
        Group = cfg.user;
        # LoadCredential = "zju-connect.toml:${config.sops.templates."zju-connect.toml".path}";

        # PrivateMounts = true; # 为服务创建独立的挂载命名空间
        # PrivateTmp = true; # 使用私有的 /tmp 目录
        # ProtectHome = true; # 禁止访问 /home, /root, /run/user 目录
        # ProtectSystem = "strict"; # 将 /usr, /boot, /etc 等目录挂载为只读
        # PrivateDevices = false; # VPN需要访问网络设备(如tun/tap)，因此不能设为true
        # NoNewPrivileges = true; # 禁止服务及其子进程获取新权限
        # LockPersonality = true; # 锁定进程的执行域，防止绕过安全策略
        # RestrictSUIDSGID = true; # 禁止创建或执行 SUID/SGID 文件
        # ProtectClock = true; # 禁止修改系统时钟
        # ProtectControlGroups = true; # 将 cgroups 层次结构设为只读
        # ProtectHostname = true; # 禁止修改系统主机名
        # ProtectKernelLogs = true; # 禁止读取内核日志
        # ProtectKernelModules = true; # 禁止加载或卸载内核模块
        # ProtectKernelTunables = true; # 将内核可调参数设为只读
        # ProtectProc = "invisible"; # 隐藏其他进程信息
        # ProcSubset = "pid"; # 仅保留进程自身的 /proc 子集
        # RestrictNamespaces = true; # 禁止创建新的命名空间
        # RestrictRealtime = true; # 禁止使用实时调度策略
        # MemoryDenyWriteExecute = true; # 禁止创建可写且可执行的内存映射
        # SystemCallArchitectures = "native"; # 仅允许原生的系统调用架构
        # SystemCallFilter = "@system-service"; # 使用 systemd 定义的系统服务通用 syscall 过滤列表
        # RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK"; # 限制网络协议族，VPN需要NETLINK来配置路由
        # CapabilityBoundingSet = "CAP_NET_ADMIN";
        # AmbientCapabilities = "CAP_NET_ADMIN";
        # User = "zju-connect";
        # Group = "zju-connect";
        # UMask = "0077"; # 文件创建掩码，确保服务创建的文件是私有的
      };
    };
  };
}
