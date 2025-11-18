{ lib, config, ... }: {
  options.openssh.authorizedKeys = with lib; mkOption {
    type = types.lines;
    description = "List of authorized SSH public keys.";
    default = "";
  };
  config = lib.mkIf (config.openssh.authorizedKeys != "") {
    home.file.".ssh/authorized_keys".text = config.openssh.authorizedKeys;
  };
}