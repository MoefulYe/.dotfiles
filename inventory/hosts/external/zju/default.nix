let
  zjuTags = [ "zju"  "fox" ];
in {
  zju-zzm.hostInfo =  {
    sshConfig= ./ssh-configs/zju-zzm.nix;
    tags = zjuTags;
  };
  zju-zhang.hostInfo = {
    sshConfig = ./ssh-configs/zju-zhang.nix;
    tags = zjuTags;
  };
  zju-yu-sg.hostInfo = {
    sshConfig = ./ssh-configs/zju-yu-sg.nix;
    tags = zjuTags;
  };
}