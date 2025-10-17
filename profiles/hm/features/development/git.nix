{ me, ... }:
{
  programs.git = {
    enable = true;
    userName = me.name;
    userEmail = me.email;
  };
}
