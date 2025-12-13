inputs: {
  ssh = import ./ssh.nix inputs;
  networks = {
    # 自定义的信息
    void = import ./networks/void.nix;
  };
}
