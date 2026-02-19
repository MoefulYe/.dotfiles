{
  # 启用 Docker（用于运行 LLM API 中转服务）
  virtualisation.docker.enable = true;
  users.users.ashenye.extraGroups = [ "docker" ];

  # Docker 优化配置（针对 1G 内存）
  virtualisation.docker.daemon.settings = {
    # 限制日志大小以节省磁盘空间
    log-driver = "json-file";
    log-opts = {
      max-size = "10m";
      max-file = "3";
    };
  };
}
