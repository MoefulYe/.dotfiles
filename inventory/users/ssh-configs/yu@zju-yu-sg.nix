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

  programs.ssh.matchBlocks."yu-sg.zju" = {
      hostname = "143.198.205.199";
      user =  "jiongchiyu";
      port =  6666;
      identityFile = "~/.config/sops-nix/secrets/YU_SG_KEY";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      compression = true;
      extraOptions = {
        TCPKeepAlive = "yes";
      };
  };
}
