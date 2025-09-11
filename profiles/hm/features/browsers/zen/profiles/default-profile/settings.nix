{ pkgs, ... }:
{
  settings = {
    "browser.link.open_newwindow" = 1;
    # https://wiki.archlinux.org/title/firefox#Hardware_video_acceleration
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
  };
}
