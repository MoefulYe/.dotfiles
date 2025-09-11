{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obsidian
    pdfannots2json # for zotero interation plugin pdf utility
  ];
}
