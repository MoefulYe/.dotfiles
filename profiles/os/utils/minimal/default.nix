{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    busybox
    # other utils ...
  ];
}
