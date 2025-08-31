{
  #  workaround for dingtalk
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}
