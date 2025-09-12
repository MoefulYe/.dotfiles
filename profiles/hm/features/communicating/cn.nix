{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qq
    # wechat
    wemeet
    nur.repos.xddxdd.dingtalk
  ];
}
