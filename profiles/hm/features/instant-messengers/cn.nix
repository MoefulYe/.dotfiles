{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.wechat
    # FIXME
    # (pkgs-stable.wechat.overrideAttrs (_: {
    #   src = pkgs.fetchurl {
    #     url = "https://web.archive.org/web/20251219062558if_/https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    #     hash = "sha256-St+iY31Kd5aRosFxFGMl5C0FsoqL5d+v2bH/3mOuNWQ=";
    #   };
    # }))
    pkgs.qq
    pkgs.wemeet
    # my-pkgs.dingtalk
  ];
}
