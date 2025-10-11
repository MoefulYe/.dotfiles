{ pkgs, lib, ... }:
# https://github.com/nix-community/home-manager/blob/master/modules/programs/firefox/mkFirefoxModule.nix#L660
let
  inherit (pkgs.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
  ccfrank = (
    buildFirefoxXpiAddon {
      pname = "ccfrank";
      addonId = "{cc79b7c3-7c57-4051-a3cc-9e9fccf5855b}";
      version = "2025-07-18";
      url = "https://addons.mozilla.org/firefox/downloads/file/4393597/ccfrank-4.5.1.xpi";
      sha256 = "OafHJ58MNU5BoGkkvOP8/pH0SFbjXvpaVfaCIhm7KuE=";
      meta = { };
    }
  );
  dup-tabs-closer = (
    buildFirefoxXpiAddon {
      pname = "dup-abs-closer";
      addonId = "jid0-RvYT2rGWfM8q5yWxIxAHYAeo5Qg@jetpack";
      version = "2025-07-18";
      url = "https://addons.mozilla.org/firefox/downloads/file/3590150/duplicate_tabs_closer-3.5.3.xpi";
      sha256 = "VivAt83Hol9vWLPiioBaPlFtIZhUfKx30iRwQMbeNX8=";
      meta = { };
    }
  );
  search-bookmark-history-tabs = (
    buildFirefoxXpiAddon {
      pname = "search-bookmark-history-tabs";
      addonId = "{bd5cec91-8853-40d9-aa80-8388a4544bd3}";
      version = "2025-07-18";
      url = "https://addons.mozilla.org/firefox/downloads/file/4505800/search_tabs_bookmarks_history-1.13.1.xpi";
      sha256 = "J4r6BT2D4e/VqG27CTXBEQn4HKy27n+YH2ETeMzddJc=";
      meta = { };
    }
  );
  search-jumper = (
    buildFirefoxXpiAddon {
      pname = "search-jumper";
      addonId = "searchjumper@hoothin.com";
      version = "2025-07-18";
      url = "https://addons.mozilla.org/firefox/downloads/file/4527813/searchjumper-1.9.3.23.xpi";
      sha256 = "dhQfgTVbNq3DjHhAeciWv4K0v7orfNJYzdf281He/WU=";
      meta = { };
    }
  );
  video-speed-controller = (
    buildFirefoxXpiAddon {
      pname = "video-speed-controller";
      addonId = "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}";
      version = "2025-07-25";
      url = "https://addons.mozilla.org/firefox/downloads/file/3756025/videospeed-0.6.3.3.xpi";
      sha256 = "3qIl81IN2Stas+8wUV83+9EnqhkcfrP6JUfS3q5SECo=";
      meta = { };
    }
  );
  ublock-origin' = (
    buildFirefoxXpiAddon {
      pname = "video-speed-controller";
      addonId = "{2f0b0183-07ed-4feb-8ac8-ce0538c6d6af}";
      version = "2025-07-25";
      url = "https://github.com/gorhill/uBlock/releases/download/1.65.1b8/uBlock0_1.65.1b8.firefox.signed.xpi";
      sha256 = "GftZH4USfvEmkUUBgy1Tzv4l0MCNWBi023Jb68v/WIU=";
      meta = { };
    }
  );
in
{
  packages = with pkgs.nur.repos.rycee.firefox-addons; [
    # 视频
    video-speed-controller
    # 脚本
    violentmonkey
    # 美化
    stylus
    # 密码
    bitwarden
    # 图片
    search-by-image
    # 标签管理
    dup-tabs-closer
    search-bookmark-history-tabs
    # ai
    chatgptbox
    # 去广告 FIXME 当前地区不可用？？？？
    ublock-origin
    # ublock-origin'
    # 隔离
    containerise
    user-agent-string-switcher
    # 快捷键
    vimium-c
    # 图片
    # 应用集成
    zotero-connector
    iina-open-in-mpv
    # 网页增强
    ccfrank
    steam-database
    fastforwardteam
    search-jumper
    # 其他
    unofficial-saladict-popup-dictionary
  ];
  force = true;
}
