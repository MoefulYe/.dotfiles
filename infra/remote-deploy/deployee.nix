{ isLinux, isDarwin, ... }:{
  users.users = if isLinux then {
    deployee = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          (builtins.readFile ./id_ed25519.pub)
        ];
        hashedPassword = "$y$j9T$t/Cvl6/8QfmSpf59G7sxt1$HO6ltOhL5Fs3HGyJ..FCRbtfWWCICoiCuUk9SmL.jsC";
    };
  } else {
    deployee = {
        openssh.authorizedKeys.keys = [
          (builtins.readFile ./id_ed25519.pub)
        ];
    };
  }; 
  security.sudo.extraConfig = ''
    deployee ALL=(ALL) NOPASSWD: ALL
  '';
}
