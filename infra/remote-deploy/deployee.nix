{
  users.users.deployee = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    createHome = true;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };
  security.sudo.extraConfig = ''
    ashenye ALL=(ALL) NOPASSWD: ALL
  '';
}
