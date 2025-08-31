{ pkgs, ... }:
{
  force = true;
  default = "bing";
  order = [
    "bing"
    "ddg"
    "google"
    "baidu"
  ];
}
