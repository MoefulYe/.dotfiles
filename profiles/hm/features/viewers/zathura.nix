{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      synctex = true;
      synctex-editor-command = "code --goto %{input}:%{line}";
    };
  };
}
