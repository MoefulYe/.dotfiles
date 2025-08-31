{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    qq
    wechat-uos
    wemeet
    nur.repos.xddxdd.dingtalk
    nur.repos.ccicnce113424.wpsoffice-365
  ];
}
