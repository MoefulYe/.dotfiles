{ config, lib, ... }:
{
  config = lib.mkIf config.userProfiles.enableZjuLabSsh {
    sops.secrets = {
      LAB_SERV_JUMP_TO_W3090 = {
        mode = "0400";
        sopsFile = ../../../../../secrets/zju.yaml;
      };
    };

    sops.templates."zju-lab.conf".content = ''
      Host jump-to-lab-serv-w3090
        HostName 10.15.201.91
        User zzm
        Port 22234
        IdentityFile ${config.sops.secrets.LAB_SERV_JUMP_TO_W3090.path}
      Host lab-serv-w3090
        HostName 172.16.0.109
        User zhao
        ProxyJump jump-to-lab-serv-w3090
    '';
    programs.ssh.includes = [
      config.sops.templates."zju-lab.conf".path
    ];
  };
}
