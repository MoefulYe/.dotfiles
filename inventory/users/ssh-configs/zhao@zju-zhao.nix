{
  config,
  paths,
  ...
}:
{
  sops.secrets = {
    JUMP_TO_ZZM = {
      mode = "0400";
      sopsFile = "${paths.secrets}/zju.yaml";
    };
  };

  sops.templates."zju-lab-serv-w3090.conf".content = ''
    Host jump-to-zhao.zju
      HostName 10.15.201.91
      User zzm
      Port 22234
      IdentityFile ${config.sops.secrets.JUMP_TO_ZZM.path}
    Host zhao.zju
      HostName 172.16.0.109
      User zhao
      ProxyJump jump-to-zhao.zju
  '';
  programs.ssh.includes = [
    config.sops.templates."zju-lab-serv-w3090.conf".path
  ];
}
