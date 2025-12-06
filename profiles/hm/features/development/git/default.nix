{ me, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        inherit (me) name email;
      };
    };
  };
}
