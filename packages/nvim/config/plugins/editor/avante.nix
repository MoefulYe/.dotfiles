{ lib, lite, ... }:
{
  # avante.nvim - AI Agent for Neovim
  # 类似 Cursor 的 AI 编辑体验，支持多模型
  # 参考：https://github.com/yetone/avante.nvim
  #
  # 配置说明：
  # - API Key 从环境变量 ANTHROPIC_API_KEY 读取
  # - 可以在 ~/.claude 或 $proj/.claude 中配置
  # - 支持项目级别的配置覆盖

  plugins.avante = lib.mkIf (!lite) {
    enable = true;

    settings = {
      # AI 提供商配置
      provider = "claude"; # 可选: "claude", "openai", "gemini", "ollama", "copilot"

      # Claude 配置 - 使用环境变量，不硬编码
      claude = {
        endpoint = "https://api.anthropic.com";
        model = "claude-sonnet-4-5-20250514";
        temperature = 0;
        max_tokens = 8000;
        api_key_name = "ANTHROPIC_API_KEY"; # 从环境变量读取
      };

      # 行为配置
      behaviour = {
        auto_suggestions = false; # 不自动建议，避免干扰
        auto_set_highlight_group = true;
        auto_set_keymaps = true;
        auto_apply_diff_after_generation = false;
        support_paste_from_clipboard = true;
      };

      # 快捷键映射
      mappings = {
        ask = "<leader>aa"; # 询问 AI
        edit = "<leader>ae"; # AI 编辑
        refresh = "<leader>ar"; # 刷新建议
        toggle = {
          default = "<leader>at"; # 切换 AI 窗口
          debug = "<leader>ad"; # 切换调试信息
          hint = "<leader>ah"; # 切换提示
        };
        diff = {
          ours = "co"; # 使用我们的版本
          theirs = "ct"; # 使用 AI 的版本
          both = "cb"; # 使用两者
          next = "]x"; # 下一个差异
          prev = "[x"; # 上一个差异
        };
        suggestion = {
          accept = "<M-l>"; # 接受建议
          next = "<M-]>"; # 下一个建议
          prev = "<M-[>"; # 上一个建议
          dismiss = "<C-]>"; # 忽略建议
        };
        jump = {
          next = "]]"; # 跳到下一个代码块
          prev = "[["; # 跳到上一个代码块
        };
        submit = {
          normal = "<CR>"; # 提交（普通模式）
          insert = "<C-s>"; # 提交（插入模式）
        };
      };

      # 窗口配置
      windows = {
        wrap = true; # 自动换行
        width = 30; # 侧边栏宽度（百分比）
        sidebar_header = {
          align = "center";
          rounded = true;
        };
        input = {
          prefix = "> ";
        };
        edit = {
          border = "rounded";
        };
      };

      # 高亮配置
      highlights = {
        diff = {
          current = "DiffText";
          incoming = "DiffAdd";
        };
      };

      # 提示配置
      hints = {
        enabled = true;
      };

      # 差异配置
      diff = {
        debug = false;
        autojump = true;
      };
    };
  };

  # 自动加载项目和用户级别的 Claude 配置
  # extraConfigLua = lib.mkIf (!lite) ''
  #   -- 读取 Claude 配置文件的函数
  #   local function load_claude_config()
  #     local home = vim.fn.expand("~")
  #     local cwd = vim.fn.getcwd()

  #     -- 配置文件路径（按优先级）
  #     local config_files = {
  #       cwd .. "/.claude",           -- 项目级配置（最高优先级）
  #       home .. "/.claude",          -- 用户级配置
  #     }

  #     local config = {}

  #     -- 依次读取配置文件
  #     for _, file in ipairs(config_files) do
  #       if vim.fn.filereadable(file) == 1 then
  #         local content = vim.fn.readfile(file)
  #         for _, line in ipairs(content) do
  #           -- 解析 KEY=VALUE 格式
  #           local key, value = line:match("^([^=]+)=(.+)$")
  #           if key and value then
  #             key = vim.trim(key)
  #             value = vim.trim(value)
  #             -- 移除引号
  #             value = value:gsub("^['\"](.+)['\"]$", "%1")
  #             config[key] = value
  #           end
  #         end
  #       end
  #     end

  #     return config
  #   end

  #   -- 应用 Claude 配置到环境变量
  #   local function apply_claude_config()
  #     local config = load_claude_config()

  #     -- 如果配置中有 API Key，设置到环境变量
  #     if config.ANTHROPIC_API_KEY and config.ANTHROPIC_API_KEY ~= "" then
  #       vim.env.ANTHROPIC_API_KEY = config.ANTHROPIC_API_KEY
  #     end

  #     -- 可以扩展支持其他配置项
  #     -- 例如：model, temperature, max_tokens 等
  #   end

  #   -- 在启动时加载配置
  #   apply_claude_config()

  #   -- 监听目录变化，重新加载配置
  #   vim.api.nvim_create_autocmd("DirChanged", {
  #     pattern = "*",
  #     callback = function()
  #       apply_claude_config()
  #     end,
  #   })
  # '';
}
