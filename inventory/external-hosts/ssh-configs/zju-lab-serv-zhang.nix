{
  config,
  paths,
  ...
}:
{
  sops.secrets = {
    ZHANG_IP = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
    ZHANG_PORT = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
    ZHANG_USER = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };

  };

  sops.templates."zju-lab-serv-zhang.conf".content = ''
    Host zju-lab-serv-zhang
      HostName ${config.sops.placeholder.ZHANG_IP}
      User ${config.sops.placeholder.ZHANG_USER}
      Port ${config.sops.placeholder.ZHANG_PORT}
  '';
  programs.ssh.includes = [
    config.sops.templates."zju-lab-serv-zhang.conf".path
  ];
}
