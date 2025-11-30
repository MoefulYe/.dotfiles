{ pkgs, ...  }: {
  services.minecraft-server = {
    enable = true;
    package = pkgs.minecraftServers.vanilla-1-21;
    eula = true;
    openFirewall = true;
    declarative = true;
    serverProperties = {
      difficulty = 3;
      server-port = 44444;
      gamemode = "survival";
      max-players = 20;
      motd = "ZJU CST MC SERVER";
      enforce-secure-profile = false;
      enable-rcon = true;
      "rcon.password" = "zju-cst-mc-server";
      online-mode = false;
    };
    jvmOpts = "-Xms8G -Xmx8G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
  };
}
