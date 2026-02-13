{
  plugins.comment = {
    enable = true;
    settings = {
      # 启用基本注释功能
      # gcc - 注释/取消注释当前行
      # gc{motion} - 注释/取消注释指定范围
      # gbc - 块注释当前行
      # gb{motion} - 块注释指定范围

      # 忽略空行
      ignore = "^$";

      # 粘性模式：在注释后保持光标位置
      sticky = true;

      # 映射配置
      mappings = {
        basic = true;
        extra = true;
      };
    };
  };
}
