{
  programs.ssh.matchBlocks = {
    "mume" = {
      hostname = "mume.void";
      user = "ashenye";
      port = 2222;
    };
    "mume.zju" = {
      hostname = "mume.void";
      user = "ashenye";
      port = 2222;
      proxyJump = "qingloong.zju";
    };
  };
}
