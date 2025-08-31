{
  imports = [
    ./zju-lab.nix
  ];
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "*" = {
      setEnv = {
        "TERM" = "xterm-256color";
      };
    };
  };
}
