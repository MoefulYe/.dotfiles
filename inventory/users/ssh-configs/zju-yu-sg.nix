{
  config,
  paths,
  ...
}:
{
  sops.secrets = {
    YU_SG_USER = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
    YU_SG_PORT = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
    YU_SG_KEY = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
    YU_SG_IP = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
  };

  sops.templates."zju-yu-sg.conf".content = ''
    Host zju-yu-sg
      HostName ${config.sops.placeholder.YU_SG_IP}
      User ${config.sops.placeholder.YU_SG_USER}
      Port ${config.sops.placeholder.YU_SG_PORT}
      IdentityFile ${config.sops.secrets.YU_SG_KEY.path}
      ServerAliveInterval 60
      ServerAliveCountMax 3
      TCPKeepAlive yes
      Compression yes
  '';
  programs.ssh.includes = [
    config.sops.templates."zju-yu-sg.conf".path
  ];
}
