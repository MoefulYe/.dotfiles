{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  kernel_6_18_3 = pkgs.linux_6_18.override {
    ignoreConfigErrors = true;
    argsOverride = rec {
      version = "6.18.3";
      modDirVersion = version;
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        hash = "sha256-eoh5FnuJxLrgd9bznE8hMHafBdva0qrZFK2rmvt9f5o=";
      };
    };
  };
  linuxPackages_6_18_3 = pkgs.linuxPackagesFor kernel_6_18_3;
  cachyosKernel = pkgs.cachyosKernels.linux-cachyos-bore-lto.override {
    pname = "my-cachyos";
    processorOpt = "x86_64-v3";
    lto = "thin";
  };
in
{
  virtualisation.docker.enable = true;
  users.users.ashenye.extraGroups = [ "docker" ];
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  boot.kernelPackages = lib.mkDefault (pkgs.linuxKernel.packagesFor cachyosKernel);
  specialisation =
    let
      boot = {
        # 1. 必须开启的调度器相关内核参数
        kernelParams = [
          "quiet"
          "loglevel=3"
          "nmi_watchdog=0" # 减少内核观测器的干扰，提高调度测量精度
          "intel_idle.max_cstate=1" # 禁用深层节能模式（C-states），防止 CPU 频率切换导致的测量偏差
          "processor.max_cstate=1"
          "cpufreq.default_governor=performance" # 强制性能模式，消除频率波动
          "nokaslr"
        ];

        # 2. Sysctl 配置：加强可观测性与性能可预测性
        kernel.sysctl = {
          "kernel.sched_rt_runtime_us" = -1; # 如果有实时任务，避免被强制限制
          "kernel.perf_event_paranoid" = -1; # 允许非 root 用户使用 perf 进行分析（这对你的数据抓取至关重要）
          "kernel.kptr_restrict" = 0; # 允许内核符号访问，便于 eBPF 追踪
          "vm.swappiness" = 10; # 降低 swap 倾向，避免内存回收干扰调度测量
          "kernel.sched_child_runs_first" = 0; # 保持可预测的父子进程调度顺序
        };
      };
    in
    {

      "nsdi-eevdf-6.18.3".configuration = {
        boot = boot // {
          kernelPackages = linuxPackages_6_18_3;
        };
      };
      "nsdi-bore-6.18.3".configuration = {
        boot = boot // {
          kernelPackages = linuxPackages_6_18_3;
          kernelPatches = [
            {
              name = "bore";
              patch = pkgs.fetchpatch {
                url = "https://raw.githubusercontent.com/firelzrd/bore-scheduler/178fd0a4bec8ad7b66facdee879602eb157c17a1/patches/stable/linux-6.18-bore/0001-linux6.18.3-bore-6.6.1.patch";
                hash = "sha256-P4FeNqAPCzRqgTYvfhCovV93pFmx2hNtwUhl3cn12qM=";
              };
              structuredExtraConfig = {
                SCHED_BORE = lib.kernel.yes;
              };
            }
          ];
        };
      };
      "nixos-lts".configuration = {
        boot.kernelPackages = pkgs.linuxPackages;
      };
    };
}
