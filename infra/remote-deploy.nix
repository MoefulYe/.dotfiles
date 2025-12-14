{
  deploy-rs,
  self,
  ...
}:
{
  nodes = {
    desk00-u265kf-lan = {
      sshUser = "ashenye";
      hostname = "lan.void";
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.desk00-u265kf-lan;
        };
        ashenye = {
          user = "ashenye";
          path =
            deploy-rs.lib.x86_64-linux.activate.home-manager
              self.homeConfigurations."ashenye@desk00-u265kf-lan";
        };
      };
    };
    lap00-xiaoxin-mei = {
      sshUser = "ashenye";
      hostname = "mei.void";
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.lap00-xiaoxin-mei;
        };
        ashenye = {
          user = "ashenye";
          path =
            deploy-rs.lib.x86_64-linux.activate.home-manager
              self.homeConfigurations."ashenye@lap00-xiaoxin-mei";
        };
      };
    };
    lap01-macm4-mume = {
      sshUser = "ashenye";
      hostname = "mume.void";
      profiles = {
        system = {
          user = "root";
          path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.lap01-macm4-mume;
        };
      };
    };
  };
  interactiveSudo = true;
}
