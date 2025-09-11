{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qq
    wechat-uos
    wemeet
    nur.repos.xddxdd.dingtalk
  ];
}
