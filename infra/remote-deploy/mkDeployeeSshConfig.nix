hosts: # lists of { hostname, domain, port }
{
  paths,
  lib,
  config,
  ...
}:
{
  sops.secrets = {
    NIX_REMOTE_BUILDER_PRIVKEY = {
      mode = "0400";
      sopsFile = "${paths.secrets}/infra.yaml";
    };
  };
  programs.ssh.matchBlocks =
    hosts
    |> lib.map (
      {
        hostname,
        domain,
        port,
      }:
      {
        name = "${hostname}-deploy";
        value = {
          hostname = domain;
          user = "deployee";
          inherit port;
          IdentityFile = config.sops.secrets.NIX_REMOTE_BUILDER_PRIVKEY.path;
        };
      }
    );
}
