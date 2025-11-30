{ pkgs, lib, ... }:
let
  bakupScript = pkgs.writeShellApplication {
    name = "minecraft-backup-script";
    runtimeInputs = [
      pkgs.mcrcon
      pkgs.gnutar
      pkgs.zstd
      pkgs.findutils
      pkgs.coreutils
    ];
    text = builtins.readFile ./minecraft-backup.sh;
  };
in
{
  # 1. 软件包依赖
  environment.systemPackages = with pkgs; [
    mcrcon
    zstd
    gnutar
  ];

  # 2. 创建备份目录
  systemd.tmpfiles.rules = [
    "d /var/lib/minecraft-bakup 0750 minecraft minecraft - -"
  ];

  # 3. 备份服务
  systemd.services.minecraft-backup = {
    description = "Minecraft Server Backup Service";
    after = [
      "network.target"
      "systemd-tmpfiles-setup.service"
    ];

    service = {
      Type = "oneshot";
      User = "minecraft";
      Group = "minecraft";
      Nice = 19;
      IOSchedulingClass = "idle";
      ProtectSystem = "full";
      PrivateTmp = true;
      ExecStart = "${lib.getExe bakupScript}";
    };

    path = with pkgs; [
      mcrcon
      gnutar
      zstd
      findutils
      coreutils
    ];
  };

  # 4. 定时器
  systemd.timers.minecraft-backup = {
    description = "Run Minecraft backup daily at 4 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
