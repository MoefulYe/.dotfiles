{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wechat
    pkgs.pkgs-25-05.qq
    wemeet
    nur.repos.xddxdd.dingtalk
  ];
}
