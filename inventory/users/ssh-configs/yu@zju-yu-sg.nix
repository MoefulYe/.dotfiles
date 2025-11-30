{
  config,
  paths,
  ...
}:
{
  sops.secrets = {
    YU_SG_KEY = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
  };

  sops.templates."zju-yu-sg.conf".content = ''
    Host zju-yu-sg
      HostName 143.198.205.199
      User jiongchiyu
      Port 6666
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
