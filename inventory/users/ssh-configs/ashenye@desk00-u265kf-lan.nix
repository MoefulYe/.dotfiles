{
  programs.ssh.matchBlocks = {
    "lan" = {
      hostname = "lan.void";
      user = "ashenye";
      port = 2222;
    };
    # FIXME: change to public IP and use VPN
    "lan.zju" = {
      hostname = "10.87.5.212";
      user = "ashenye";
      port = 2222;
    };
  };
}
