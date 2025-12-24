{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    history = {
      size = 10000;
      ignoreAllDups = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "wd"
        "history"
        "extract"
        "systemd"
        "fzf"
      ];
      extraConfig = ''
        COMPLETION_WAITING_DOTS=true
      '';
    };
    shellAliases = {
      lg = "lazygit";
      ls = "lsd --hyperlink=auto";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      e = "printenv";
      o = "xdg-open";
      j = "journalctl";
      js = "just";
      s = "ssh";
      st = "systemctl";
      stu = "systemctl --user";
      pd = "podman";
      pdr = "podman run";
      pdb = "podman build";
      pde = "podman exec";
      pdc = "podman compose";
      pdv = "podman volume";
      run = "systemd-run --user";
      icat = "kitty +kitten icat";
      ac = "source .venv/bin/activate";
      de = "deactivate";
      zj = "zellij";
      tl = "tldr";
      sshj = "SHELL=$(which bash) ssh";
    };
    initContent = builtins.readFile ./init_content.sh;
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      direnv.disabled = false;
      directory = {
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };
      git_metrics.disabled = false;
      git_status = {
        diverged = "⇡$ahead_count⇣$behind_count";
        conflicted = "=$count";
        ahead = "⇡$count";
        behind = "⇣$count";
        untracked = "?$count";
        stashed = "+$count";
        modified = "!$count";
        staged = "\\$$count";
        renamed = "»$count";
        deleted = "✘$count";
      };
      localip = {
        ssh_only = false;
        disabled = false;
      };
      memory_usage.disabled = false;
      os.disabled = false;
      shell.disabled = false;
      shlvl.disabled = false;
      status.disabled = false;
      sudo.disabled = false;
      time.disabled = false;
      continuation_prompt = "▶▶ ";
      fill.symbol = " ";
      format = "$os$all";
    };
  };
}
