{
  programs.ssh.matchBlocks = {
    "citrus" = {
      hostname = "45.192.104.103";
      user = "ashenye";
      port = 2222;
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      compression = true;
      extraOptions = {
        TCPKeepAlive = "yes";
      };
    };
  };
}
