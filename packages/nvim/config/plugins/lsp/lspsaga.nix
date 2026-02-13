_: {
  # Lspsaga - 更好的 LSP UI
  # 提供浮动窗口、代码操作预览、更美观的诊断显示等功能
  # 参考：https://github.com/nvimdev/lspsaga.nvim

  plugins.lspsaga = {
    enable = true;
    settings = {
      # UI 配置
      ui = {
        border = "rounded";
        code_action = "💡";
        title = true;
        winblend = 0;
        expand = "";
        collapse = "";
        preview = " ";
        code_action_icon = "💡";
        diagnostic = "🐞";
        incoming = " ";
        outgoing = " ";
      };

      # 灯泡图标（代码操作提示）
      lightbulb = {
        enable = false; # 禁用灯泡图标，避免干扰
        sign = false;
        virtual_text = false;
      };

      # 在 winbar 中显示符号路径
      symbol_in_winbar = {
        enable = true;
        separator = " › ";
        hide_keyword = true;
        show_file = true;
        folder_level = 2;
      };

      # 代码操作配置
      code_action = {
        num_shortcut = true;
        show_server_name = true;
        extend_gitsigns = true;
      };

      # 诊断配置
      diagnostic = {
        show_code_action = true;
        show_source = true;
        jump_num_shortcut = true;
        max_width = 0.7;
        max_height = 0.8;
        text_hl_follow = true;
        border_follow = true;
      };

      # 悬停文档配置
      hover = {
        max_width = 0.6;
        max_height = 0.8;
        open_link = "gx";
        open_browser = "!open";
      };

      # 定义和引用配置
      definition = {
        edit = "<C-c>o";
        vsplit = "<C-c>v";
        split = "<C-c>i";
        tabe = "<C-c>t";
        quit = "q";
      };

      # 重命名配置
      rename = {
        quit = "<C-c>";
        exec = "<CR>";
        mark = "x";
        confirm = "<CR>";
        in_select = true;
      };

      # 大纲配置
      outline = {
        win_position = "right";
        win_with = "";
        win_width = 30;
        show_detail = true;
        auto_preview = true;
        auto_refresh = true;
        auto_close = true;
        custom_sort = null;
        keys = {
          jump = "o";
          expand_collapse = "u";
          quit = "q";
        };
      };

      # Callhierarchy 配置
      callhierarchy = {
        show_detail = false;
        keys = {
          edit = "e";
          vsplit = "s";
          split = "i";
          tabe = "t";
          jump = "o";
          quit = "q";
          expand_collapse = "u";
        };
      };

      # Beacon 配置（跳转时的光标提示）
      beacon = {
        enable = true;
        frequency = 7;
      };

      # 滚动预览配置
      scroll_preview = {
        scroll_down = "<C-f>";
        scroll_up = "<C-b>";
      };

      # 请求超时
      request_timeout = 2000;
    };
  };

  # Lspsaga 快捷键
  keymaps = [
    # 诊断导航
    {
      key = "[d";
      action = "<CMD>Lspsaga diagnostic_jump_prev<CR>";
      options.desc = "Previous Diagnostic";
    }
    {
      key = "]d";
      action = "<CMD>Lspsaga diagnostic_jump_next<CR>";
      options.desc = "Next Diagnostic";
    }

    # 悬停文档
    {
      key = "K";
      action = "<CMD>Lspsaga hover_doc<CR>";
      options.desc = "Hover Documentation";
    }

    # 代码操作
    {
      key = "<leader>la";
      action = "<CMD>Lspsaga code_action<CR>";
      mode = [
        "n"
        "v"
      ];
      options.desc = "Code Action";
    }

    # 重命名
    {
      key = "<leader>lr";
      action = "<CMD>Lspsaga rename<CR>";
      options.desc = "Rename";
    }

    # 查看定义
    {
      key = "gd";
      action = "<CMD>Lspsaga peek_definition<CR>";
      options.desc = "Peek Definition";
    }
    {
      key = "gD";
      action = "<CMD>Lspsaga goto_definition<CR>";
      options.desc = "Goto Definition";
    }

    # 查看类型定义
    {
      key = "gt";
      action = "<CMD>Lspsaga peek_type_definition<CR>";
      options.desc = "Peek Type Definition";
    }
    {
      key = "gT";
      action = "<CMD>Lspsaga goto_type_definition<CR>";
      options.desc = "Goto Type Definition";
    }

    # 查找引用
    {
      key = "gr";
      action = "<CMD>Lspsaga finder<CR>";
      options.desc = "Find References";
    }

    # 大纲
    {
      key = "<leader>lo";
      action = "<CMD>Lspsaga outline<CR>";
      options.desc = "Toggle Outline";
    }

    # 调用层级
    {
      key = "<leader>lc";
      action = "<CMD>Lspsaga incoming_calls<CR>";
      options.desc = "Incoming Calls";
    }
    {
      key = "<leader>lC";
      action = "<CMD>Lspsaga outgoing_calls<CR>";
      options.desc = "Outgoing Calls";
    }

    # 诊断
    {
      key = "<leader>ld";
      action = "<CMD>Lspsaga show_line_diagnostics<CR>";
      options.desc = "Line Diagnostics";
    }
    {
      key = "<leader>lD";
      action = "<CMD>Lspsaga show_buf_diagnostics<CR>";
      options.desc = "Buffer Diagnostics";
    }
  ];
}
