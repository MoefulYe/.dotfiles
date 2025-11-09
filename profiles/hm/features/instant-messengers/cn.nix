{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs-stable.wechat
    pkgs-stable.qq
    pkgs-stable.wemeet
    my-pkgs.dingtalk
  ];
}
