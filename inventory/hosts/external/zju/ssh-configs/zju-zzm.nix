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

  sops.templates."zju-zzm.conf".content = ''
    Host jump-to-zju-zzm
      HostName 10.15.201.91
      User zzm
      Port 22234
      IdentityFile ${config.sops.secrets.JUMP_TO_ZZM.path}
    Host zju-zzm
      HostName 172.16.0.109
      User zhao
      ProxyJump jump-to-zju-zzm
  '';
  programs.ssh.includes = [
    config.sops.templates."zju-zzm.conf".path
  ];
}
