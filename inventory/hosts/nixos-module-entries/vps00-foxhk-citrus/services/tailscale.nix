{ config, pkgs, ... }:

{
  # 1. 启用 Tailscale 客户端（作为节点加入网络是必要的）
  services.tailscale.enable = true;

  # 2. 配置 DERP 服务
  services.tailscale.derper = {
    enable = true;

    # 你的 DERP 服务器域名
    # 注意：你必须拥有此域名，并配置 DNS A 记录指向该服务器 IP
    domain = "derp.059867.xyz";

    # 自动配置 Nginx 作为反向代理
    # 这一步会自动处理 Let's Encrypt SSL 证书申请和续期
    configureNginx = true;

    # 自动打开服务器的系统防火墙端口
    # 包括 TCP 80/443 (用于 Web/SSL) 和 UDP 3478 (用于 STUN 协议)
    openFirewall = true;

    # (可选) 如果你想修改默认的 STUN 端口，默认为 3478
    # stunPort = 3478;
  };

  # 3. 配置 ACME (Let's Encrypt) 必须的邮箱
  security.acme = {
    acceptTerms = true;
    defaults.email = "luren145@gmail.com"; # 替换为你的真实邮箱
  };
  services.nginx.virtualHosts."derp.059867.xyz" = {
    enableACME = true;
  };
}
