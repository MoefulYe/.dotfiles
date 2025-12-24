{
  programs.ssh.matchBlocks = {
    "lan" = {
      hostname = "lan.void";
      user = "ashenye";
      port = 2222;
    };
    "lan.zju" = {
      hostname = "lan.void";
      user = "ashenye";
      port = 2222;
      proxyJump = "qingloong.zju";
    };
  };
}
