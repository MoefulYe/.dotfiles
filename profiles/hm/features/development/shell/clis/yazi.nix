{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      opener = {
        open = [
          {
            run = ''xdg-open "$@"'';
            desc = "open";
            for = "linux";
          }
        ];
      };
    };
  };
}
