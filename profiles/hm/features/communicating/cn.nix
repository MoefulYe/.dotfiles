{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wechat
    qq
    wemeet
    nur.repos.xddxdd.dingtalk
  ];
}
