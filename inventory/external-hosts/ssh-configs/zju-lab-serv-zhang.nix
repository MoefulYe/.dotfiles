{
  config,
  paths,
  ...
}:
{
  sops.secrets = {
    LAB_SERV_ZHANG = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
  };

  sops.templates."zju-lab-serv-zhang.conf".content = ''
    Host zju-lab-serv-zhang
      HostName 10.22.81.253
      User ubuntu
      Port 14222
  '';
  programs.ssh.includes = [
    config.sops.templates."zju-lab-serv-zhang.conf".path
  ];
}
