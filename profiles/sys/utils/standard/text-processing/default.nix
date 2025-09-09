{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    ripgrep
    jq 
    yq-go
  ];
}