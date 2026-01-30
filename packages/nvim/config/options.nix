{
  # Clipboard
  clipboard = {
    providers.wl-copy.enable = true;
    register = "unnamedplus";
  };

  # Vim options
  opts = {
    number = true;
    relativenumber = true;

    tabstop = 2;
    softtabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;

    cursorline = true;
    scrolloff = 8;
    mouse = "a";

    foldmethod = "manual";
    foldenable = false;
    linebreak = true;
    spell = false;
    swapfile = false;

    timeoutlen = 300;
    termguicolors = true;
    showmode = false;

    splitbelow = true;
    splitright = true;
    splitkeep = "screen";

    cmdheight = 0;
    showtabline = 2;

    fillchars = { eob = " "; };
  };

  # Diagnostic signs
  extraConfigLuaPre = ''
    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticHint" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticInfo" })
  '';
}
