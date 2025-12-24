{
  programs.ssh.matchBlocks = {
    "mei" = {
      hostname = "mei.void";
      user = "ashenye";
      port = 2222;
    };
    "mei.zju" = {
      hostname = "mei.void";
      user = "ashenye";
      port = 2222;
      proxyJump = "qingloong.zju";
    };
  };
}
