{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs-25-05.wechat
    pkgs-25-05.qq
    pkgs-25-05.wemeet
    my-pkgs.dingtalk
  ];
}
