{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    aria2
  ]; 
  sops.secrets = {
    ARIA2_PASSWD = {
      mode = "0400";
      sopsFile = "${paths.secrets}/app-secrets.yaml";
    };
  };

  services.aria2 = {
    enable = true;
    settings.rpcSecretFile = "/run/secrets/ARIA2_PASSWD";
  };
}