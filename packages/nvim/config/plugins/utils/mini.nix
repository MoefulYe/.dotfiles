{
  plugins.mini = {
    enable = true;

    modules = {
      indentscope = {
        symbol = "│";
        options = {
          try_as_border = true;
        };
        draw = {
          delay = 0;
          animation.__raw = "require('mini.indentscope').gen_animation.none()";
        };
      };
      surround = { };
    };
  };
}
