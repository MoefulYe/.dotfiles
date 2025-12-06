{ pkgs, isLinux, ... }:
{
  home.packages =
    with pkgs;
    [
      obsidian
      pdfannots2json # for zotero interation plugin pdf utility
      xournalpp
      zotero
    ]
    ++ (lib.optionals isLinux [
      typora
    ]);
}
