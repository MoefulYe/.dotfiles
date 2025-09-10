{ pkgs, lib, config, ... }: {
  options.hostInfo = with lib; {
    hostname = mkOption {
      type = types.str;
    };
    system = mkOption {
      type = types.str;
    };
    tags = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    description = mkOption {
      type = types.str;
      default = "";
    };
  };
}