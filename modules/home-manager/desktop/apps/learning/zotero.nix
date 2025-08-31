{ pkgs, ... }:
let
  # for now, I dont nixify zotero.
  # I just simply record what extensions I use and other settings.
  # And manually install them
  extensions = {
    "Awesome GPT" = "https://github.com/MuiseDestiny/zotero-gpt#readme";
    "Jasminum" = "https://github.com/l0o0/jasminum#readme";
    "Linter for Zotero" = "https://github.com/northword/zotero-format-metadata#readme";
    "Nutstore" = "https://github.com/nutstore/zotero-plugin-nutstore#readme";
    "Translate for Zotero" = "https://github.com/windingwind/zotero-pdf-translate#readme";
    "Better BibTex for Zotero" = "https://github.com/retorquere/zotero-better-bibtex";
  };
  # obsidian integration: https://pkmer.cn/Pkmer-Docs/10-obsidian/obsidian%E4%BD%BF%E7%94%A8%E6%8A%80%E5%B7%A7/zotero%E5%92%8Cobsidian%E8%81%94%E5%8A%A8/#51-%E6%8F%92%E5%85%A5%E5%BC%95%E6%96%87
in
{
  home.packages = with pkgs; [
    zotero
  ];
}
