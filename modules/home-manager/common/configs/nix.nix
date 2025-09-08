{
  config,
  ...
}:
{
  sops.secrets.GITHUB_ACCESS_TOKEN = {
    sopsFile = ../../../../secrets/api-tokens.yaml;
  };
  sops.templates."nix.conf".content = ''
    access-tokens = github.com=${config.sops.placeholder.GITHUB_ACCESS_TOKEN}
  '';
  sops.templates."nix.conf".path = "${config.xdg.configHome}/nix/nix.conf";
}
