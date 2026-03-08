{
  programs.ssh.matchBlocks = {
    "zhuque" = {
      hostname = "zhuque.void";
      user = "root";
      port = 2222;
    };
    "zhuque.zju" = {
      hostname = "zhuque.void";
      user = "root";
      port = 2222;
      proxyJump = "qingloong.zju";
    };
  };
}
