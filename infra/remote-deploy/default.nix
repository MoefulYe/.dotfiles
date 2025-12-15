{
  outputs,
  inputs,
  ...
}:
let
  inherit (inputs) deploy-rs;
in
{
  nodes = {
    # desk00-u265kf-lan = {
    #   sshUser = "ashenye";
    #   hostname = "lan.void";
    #   profiles = {
    #     system = {
    #       user = "root";
    #       path = deploy-rs.lib.x86_64-linux.activate.nixos outputs.nixosConfigurations.desk00-u265kf-lan;
    #     };
    #     ashenye = {
    #       user = "ashenye";
    #       path =
    #         deploy-rs.lib.x86_64-linux.activate.home-manager
    #           outputs.homeConfigurations."ashenye@desk00-u265kf-lan";
    #     };
    #   };
    # };
    lap00-xiaoxin-mei = {
      sshUser = "ashenye";
      hostname = "mei.void";
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos outputs.nixosConfigurations.lap00-xiaoxin-mei;
          interactiveSudo = true;
        };
        ashenye = {
          user = "ashenye";
          path =
            deploy-rs.lib.x86_64-linux.activate.home-manager
              outputs.homeConfigurations."ashenye@lap00-xiaoxin-mei";
        };
      };
    };
    lap01-macm4-mume = {
      sshUser = "ashenye";
      hostname = "mume.void";
      remoteBuild = true;
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib.aarch64-darwin.activate.darwin outputs.darwinConfigurations.lap01-macm4-mume;
          interactiveSudo = true;
        };
      };
    };
  };
}
