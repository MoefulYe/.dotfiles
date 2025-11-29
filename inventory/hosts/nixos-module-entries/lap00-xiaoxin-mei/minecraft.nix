{ pkgs, ...  }: {
  services.minecraft-server = {
    enable = true;
    package = minecraftServer.vanilla-1-21;
    eula = true;
    openFirewall = true;
    serverProperties = {
      server-port = 43000;
      difficulty = 3;
      gamemode = 1;
      max-players = 20;
      motd = "ZJU CST MC SERVER";
    };
  };
}
