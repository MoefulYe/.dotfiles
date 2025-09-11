{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [
          "*"
          "-256c:0064:22ace4d0"
        ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
            esc = "capslock";
          };
        };
      };
      gaomon-pad = {
        ids = [ "256c:0064:22ace4d0" ];
        settings = {
          main = {
            "f13" = "C-0";
            "f14" = "C-minus";
            "f15" = "C-equal";
            "f16" = "C-s";
            "f17" = "C-S-h";
            "f18" = "C-S-p";
            "f19" = "C-S-e";
            "f20" = "C-z";
            "f21" = "C-y";
          };
        };
      };
    };
  };
}
