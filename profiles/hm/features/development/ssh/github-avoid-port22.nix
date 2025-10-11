{
  # 为了避免用户使用代理黑别人服务器和 DDOS，部分机场可能会禁用 22 端口
  # 导致 GITHUB 无法通过代理 SSH 访问
  # 不过幸运的是 GITHUB 提供了另外一种连接方式，可以走 443 端口
  programs.ssh.matchBlocks = {
    "github.com" = {
      "Hostname" = "ssh.github.com";
      "Port" = "443";
    };
  };
}
