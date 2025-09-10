{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    btop
    lsof
    ncdu
  ];
}