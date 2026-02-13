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
      provider = "acloud"; # 可选: "claude", "openai", "gemini", "ollama", "copilot"

      # Claude 配置 - 使用环境变量，不硬编码
      providers = {
        acloud = {
          __inherited_from = "openai";
          endpoint = "https://acloudvip.top/v1";
          model = "claude-sonnet-4-5-20250929";
        };
      };

      # 行为配置
      behaviour = {
        auto_suggestions = false; # 不自动建议，避免干扰
        auto_set_highlight_group = true;
        auto_set_keymaps = true;
        auto_apply_diff_after_generation = false;
        support_paste_from_clipboard = true;
      };
    };
  };
}
