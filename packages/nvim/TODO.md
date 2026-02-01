# Neovim Configuration TODO

## 🎯 迁移状态

### ✅ 已完成
- [x] 基础配置迁移（options, keymaps, autocommands）
- [x] LSP 插件迁移（lsp, conform, dap, fidget + 10 种语言）
- [x] 补全插件迁移（cmp + copilot + autopairs + lspkind）
- [x] 编辑器插件迁移（treesitter, neo-tree, copilot-chat, illuminate 等）
- [x] UI 插件迁移（bufferline, lualine）
- [x] 工具插件迁移（telescope 完整配置, whichkey, toggleterm 等）
- [x] Git 插件迁移（gitsigns, lazygit）
- [x] Snippet 插件迁移（luasnip）
- [x] Standalone 模式实现（可独立运行）
- [x] Lite 模式支持（精简配置用于低性能设备）

### ⚠️ 已知问题
- [ ] startup.nvim 已禁用（配置格式在 nixvim 中已改变）
- [ ] treesitter folding 警告（已修复但需验证）

---

## 📋 待办事项

## 1. 🔄 插件升级和替换

### 高优先级

#### 1.1 替换 nvim-cmp 为 blink.cmp
**原因**：性能提升 10-20 倍，用 Rust 编写，更智能的补全

**任务**：
- [ ] 添加 blink.cmp 插件配置
- [ ] 迁移 nvim-cmp 的 sources 配置
- [ ] 迁移快捷键配置
- [ ] 测试补全功能
- [ ] 移除旧的 nvim-cmp 配置

**配置示例**：
```nix
plugins.blink-cmp = {
  enable = true;
  settings = {
    keymap.preset = "default";
    sources.default = [ "lsp" "path" "buffer" "copilot" ];
    completion = {
      menu.border = "rounded";
      documentation.window.border = "rounded";
    };
  };
};
```

**参考**：
- https://github.com/Saghen/blink.cmp
- nixvim blink-cmp 文档

---

#### 1.2 替换 startup.nvim
**原因**：当前配置已损坏，nixvim 格式已改变

**选项 A：snacks.nvim（推荐）**
- [ ] 添加 snacks.nvim 配置
- [ ] 配置 dashboard
- [ ] 配置 notifier
- [ ] 配置 statuscolumn
- [ ] 测试启动画面

```nix
plugins.snacks = {
  enable = true;
  settings = {
    dashboard = {
      enable = true;
      preset = {
        header = ''
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          [ASCII art...]
        '';
        keys = [
          { icon = " "; key = "f"; desc = "Find File"; action = ":Telescope find_files"; }
          { icon = " "; key = "r"; desc = "Recent Files"; action = ":Telescope oldfiles"; }
          { icon = " "; key = "g"; desc = "Find Text"; action = ":Telescope live_grep"; }
          { icon = " "; key = "c"; desc = "Config"; action = ":e $MYVIMRC"; }
          { icon = " "; key = "q"; desc = "Quit"; action = ":qa"; }
        ];
      };
    };
    notifier.enable = true;
    statuscolumn.enable = true;
  };
};
```

**选项 B：alpha.nvim**
- [ ] 添加 alpha.nvim 配置
- [ ] 配置启动画面布局
- [ ] 配置快捷按钮
- [ ] 测试启动画面

**选项 C：mini.starter**
- [ ] 添加 mini.starter 配置
- [ ] 配置启动项
- [ ] 测试启动画面

**参考**：
- https://github.com/folke/snacks.nvim
- https://github.com/goolord/alpha-nvim

---

#### 1.3 添加 Avante.nvim（AI Agent）
**原因**：类似 Cursor 的 AI 编辑体验，支持多模型，内联对话和代码编辑

**任务**：
- [ ] 添加 avante.nvim 配置
- [ ] 配置 Claude API（或其他 AI 提供商）
- [ ] 配置快捷键
- [ ] 配置 UI 样式
- [ ] 测试 AI 对话功能
- [ ] 测试代码编辑建议
- [ ] 测试多轮对话

**配置示例**：
```nix
plugins.avante = {
  enable = true;
  settings = {
    provider = "claude";  # 或 "openai", "gemini", "ollama"
    claude = {
      endpoint = "https://api.anthropic.com";
      model = "claude-sonnet-4-5";
      temperature = 0;
      max_tokens = 4096;
      api_key_name = "ANTHROPIC_API_KEY";  # 环境变量名
    };
    behaviour = {
      auto_suggestions = false;  # 不自动建议，避免干扰
      auto_set_highlight_group = true;
      auto_set_keymaps = true;
    };
    mappings = {
      ask = "<leader>aa";        # 询问 AI
      edit = "<leader>ae";       # AI 编辑
      refresh = "<leader>ar";    # 刷新建议
      toggle = "<leader>at";     # 切换 AI 窗口
    };
    windows = {
      wrap = true;
      width = 30;  # 侧边栏宽度（百分比）
      sidebar_header = {
        align = "center";
        rounded = true;
      };
    };
    highlights = {
      diff = {
        current = "DiffText";
        incoming = "DiffAdd";
      };
    };
  };
};
```

**使用场景**：
- 复杂重构：`<leader>aa` "重构这个函数，使用更好的错误处理"
- 代码解释：`<leader>aa` "解释这段代码的工作原理"
- 生成代码：`<leader>ae` "添加单元测试"
- 优化代码：`<leader>ae` "优化这个算法的性能"

**与 Copilot 的分工**：
- **Copilot**：快速补全，单行/多行代码建议
- **Avante**：复杂任务，多轮对话，代码重构，解释说明
- **Claude Code**：跨文件操作，架构设计，大规模重构

**参考**：
- https://github.com/yetone/avante.nvim
- nixvim avante 文档（如果有）

---

#### 1.4 添加 lspsaga
**原因**：更好的 LSP UI，浮动窗口，更美观

**任务**：
- [ ] 添加 lspsaga 配置
- [ ] 配置快捷键
- [ ] 配置 UI 样式
- [ ] 测试各项功能（定义、引用、重命名等）

```nix
plugins.lspsaga = {
  enable = true;
  settings = {
    ui = {
      border = "rounded";
      code_action = "💡";
    };
    lightbulb = {
      enable = false;  # 禁用灯泡图标（可能干扰）
    };
    symbol_in_winbar = {
      enable = true;
    };
  };
};
```

**参考**：
- https://github.com/nvimdev/lspsaga.nvim

---

### 中优先级

#### 1.4 添加 render-markdown.nvim
**原因**：更好的 markdown 实时渲染

**任务**：
- [ ] 添加 render-markdown 配置
- [ ] 配置渲染样式
- [ ] 测试 markdown 文件显示

```nix
plugins.render-markdown = {
  enable = true;
  settings = {
    heading = {
      enabled = true;
      sign = true;
      icons = [ "󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 " ];
    };
    code = {
      enabled = true;
      sign = true;
      style = "full";
    };
  };
};
```

---

#### 1.5 添加 actions-preview.nvim
**原因**：更好的 code action 预览

**任务**：
- [ ] 添加 actions-preview 配置
- [ ] 配置快捷键
- [ ] 测试 code action 预览

---

#### 1.6 添加 tiny-inline-diagnostic.nvim
**原因**：更好的内联诊断显示

**任务**：
- [ ] 添加 tiny-inline-diagnostic 配置
- [ ] 配置显示样式
- [ ] 测试诊断显示

---

### 低优先级（可选）

#### 1.7 考虑替换 neo-tree 为 oil.nvim
**原因**：更符合 Vim 哲学，像编辑文件一样编辑目录

**任务**：
- [ ] 评估是否需要替换
- [ ] 如果需要，添加 oil.nvim 配置
- [ ] 迁移快捷键
- [ ] 测试文件操作

---

#### 1.8 考虑替换 lualine 为 mini.statusline
**原因**：更轻量，更快

**任务**：
- [ ] 评估是否需要替换
- [ ] 如果需要，添加 mini.statusline 配置
- [ ] 迁移状态栏配置
- [ ] 测试显示效果

---

## 2. ⌨️ 快捷键优化

### 2.1 审查和整理现有快捷键
**任务**：
- [ ] 列出所有快捷键（从 keymaps.nix 和各插件配置）
- [ ] 检查冲突的快捷键
- [ ] 检查未使用的快捷键
- [ ] 创建快捷键分类表

### 2.2 统一快捷键风格
**任务**：
- [ ] 统一 leader key 使用规范
  - `<leader>f` - Find/File 相关
  - `<leader>g` - Git 相关
  - `<leader>l` - LSP 相关
  - `<leader>s` - Search 相关
  - `<leader>t` - Terminal/Toggle 相关
  - `<leader>u` - UI 相关
  - `<leader>w` - Window 相关
- [ ] 确保所有快捷键都有 which-key 描述
- [ ] 移除重复或冲突的快捷键

### 2.3 优化常用操作
**任务**：
- [ ] 确保最常用的操作有最方便的快捷键
- [ ] 添加缺失的快捷键
- [ ] 优化 LSP 相关快捷键（配合 lspsaga）

### 2.4 添加新插件快捷键
**任务**：
- [ ] blink.cmp 快捷键
- [ ] snacks.nvim 快捷键
- [ ] lspsaga 快捷键
- [ ] 其他新插件快捷键

### 2.5 创建快捷键文档
**任务**：
- [ ] 创建 KEYMAPS.md 文档
- [ ] 按功能分类列出所有快捷键
- [ ] 添加使用说明和示例

---

## 3. 📁 目录结构重构

### 3.1 当前结构分析
```
packages/nvim/config/
├── autocommands.nix
├── default.nix
├── keymaps.nix
├── options.nix
└── plugins/
    ├── cmp/              # 6 个文件
    │   ├── autopairs.nix
    │   ├── cmp-copilot.nix
    │   ├── cmp.nix
    │   ├── default.nix
    │   ├── lspkind.nix
    │   └── schemastore.nix
    ├── colorscheme.nix
    ├── default.nix
    ├── editor/           # 9 个文件
    │   ├── copilot-chat.nix
    │   ├── default.nix
    │   ├── illuminate.nix
    │   ├── indent-blankline.nix
    │   ├── navic.nix
    │   ├── neo-tree.nix
    │   ├── todo-comments.nix
    │   ├── treesitter.nix
    │   └── undotree.nix
    ├── git/              # 3 个文件
    │   ├── default.nix
    │   ├── gitsigns.nix
    │   └── lazygit.nix
    ├── lsp/              # 多个文件
    │   ├── conform.nix
    │   ├── dap.nix
    │   ├── default.nix
    │   ├── fidget.nix
    │   ├── langs/
    │   │   ├── cmake.nix
    │   │   ├── config-langs.nix
    │   │   ├── cxx.nix
    │   │   ├── default.nix
    │   │   ├── just.nix
    │   │   ├── lua.nix
    │   │   ├── nix.nix
    │   │   ├── php.nix
    │   │   ├── python.nix
    │   │   └── rust.nix
    │   └── lsp.nix
    ├── snippet/          # 1 个文件
    │   └── default.nix
    ├── telescope.nix
    ├── treesitter.nix
    ├── ui/               # 4 个文件
    │   ├── bufferline.nix
    │   ├── default.nix
    │   ├── lualine.nix
    │   └── startup.nix
    └── utils/            # 8 个文件
        ├── comment.nix
        ├── default.nix
        ├── markdown-preview.nix
        ├── mini.nix
        ├── toggleterm.nix
        ├── web-devicons.nix
        └── whichkey.nix
```

**问题**：
- 文件过于分散（50+ 个文件）
- 有些目录只有 1-2 个文件
- 结构不够清晰
- telescope.nix 和 treesitter.nix 在根目录，不一致

### 3.2 建议的新结构

**方案 A：按功能合并（推荐）**
```
packages/nvim/
├── config/
│   ├── core/                    # 核心配置
│   │   ├── options.nix          # Vim 选项
│   │   ├── keymaps.nix          # 全局快捷键
│   │   └── autocommands.nix     # 自动命令
│   ├── plugins/
│   │   ├── completion.nix       # 合并所有补全相关（cmp, copilot, autopairs）
│   │   ├── lsp.nix             # 合并所有 LSP 相关（lsp, conform, dap, fidget）
│   │   ├── editor.nix          # 合并编辑器功能（treesitter, neo-tree, illuminate 等）
│   │   ├── ui.nix              # 合并 UI 插件（bufferline, lualine, dashboard）
│   │   ├── git.nix             # Git 相关
│   │   ├── telescope.nix       # Telescope（保持独立，配置较多）
│   │   ├── colorscheme.nix     # 主题
│   │   └── default.nix         # 插件入口
│   ├── langs/                   # 语言特定配置
│   │   ├── nix.nix
│   │   ├── rust.nix
│   │   ├── python.nix
│   │   ├── lua.nix
│   │   ├── cxx.nix
│   │   └── default.nix
│   └── default.nix              # 主入口
├── default.nix                  # Package 定义
└── TODO.md                      # 本文件
```

**方案 B：保持当前结构，只做小调整**
```
packages/nvim/config/
├── core/                        # 新增：核心配置目录
│   ├── options.nix
│   ├── keymaps.nix
│   └── autocommands.nix
└── plugins/                     # 保持现有结构
    ├── cmp/
    ├── lsp/
    ├── editor/
    ├── ui/
    ├── utils/
    ├── git/
    ├── snippet/
    ├── telescope.nix
    ├── treesitter.nix           # 移到 editor/ 下
    ├── colorscheme.nix
    └── default.nix
```

### 3.3 重构任务
- [ ] 决定使用哪个方案
- [ ] 创建新的目录结构
- [ ] 迁移配置文件
- [ ] 更新 imports
- [ ] 测试构建
- [ ] 删除旧文件

---

## 4. 🎨 Startup 插件替换

见 **1.2 替换 startup.nvim**

---

## 5. 🚀 其他优化和完善

### 5.1 性能优化

#### 5.1.1 启用 Lazy Loading
**任务**：
- [ ] 分析哪些插件可以延迟加载
- [ ] 配置按需加载的插件
- [ ] 测试启动时间

**示例**：
```nix
# 某些插件可以在特定事件时加载
plugins.neo-tree = {
  enable = true;
  lazy = true;
  cmd = [ "Neotree" ];  # 只在执行命令时加载
};
```

#### 5.1.2 优化 Treesitter Grammar
**任务**：
- [ ] 审查当前的 grammar 列表
- [ ] 移除不使用的语言
- [ ] 只保留常用语言

**当前 Full 模式的 grammars**（需要精简）：
```nix
# 当前有 90+ 个 grammars，很多可能不需要
grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
  astro awk bash c cmake comment cpp css csv cuda diff dockerfile
  git_config git_rebase gitattributes gitcommit gitignore glsl
  # ... 太多了
];
```

**建议保留**：
```nix
# 只保留常用的
grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
  # 系统和配置
  bash nix lua vim vimdoc
  # 编程语言
  c cpp rust python go javascript typescript
  # 标记语言
  markdown markdown_inline json yaml toml
  # 其他
  git_config gitcommit diff comment regex
];
```

#### 5.1.3 测试启动时间
**任务**：
- [ ] 运行 `nvim --startuptime startup.log`
- [ ] 分析慢的插件
- [ ] 优化加载顺序

---

### 5.2 功能完善

#### 5.2.1 迁移 Snippets 配置
**任务**：
- [ ] 检查原来的 snippets 目录（`profiles/hm/features/development/neovim/snippets/`）
- [ ] 迁移 snippet 文件到新位置
- [ ] 配置 luasnip 加载路径
- [ ] 测试 snippets 功能

**原始 snippets**：
```
snippets/
├── comment.txt
├── global.json
├── nix.json
├── package.json
└── shell.json
```

**新位置建议**：
```
packages/nvim/snippets/
├── global.json
├── nix.json
└── shell.json
```

**配置**：
```nix
plugins.luasnip = {
  enable = true;
  settings = {
    enable_autosnippets = true;
    store_selection_keys = "<Tab>";
  };
  fromVscode = [
    { paths = ./snippets; }
  ];
};
```

#### 5.2.2 完善 DAP 配置
**任务**：
- [ ] 添加 nvim-dap-ui 配置
- [ ] 配置常用语言的 DAP
- [ ] 添加调试快捷键
- [ ] 测试调试功能

#### 5.2.3 添加 Project-specific 配置
**任务**：
- [ ] 添加 .nvim.lua 或 .exrc 支持
- [ ] 配置项目特定的 LSP 设置
- [ ] 配置项目特定的格式化规则

---

### 5.3 文档和注释

#### 5.3.1 添加配置注释
**任务**：
- [ ] 给每个插件配置添加注释说明
  - 插件用途
  - 主要功能
  - 快捷键
- [ ] 添加配置示例
- [ ] 添加参考链接

**示例**：
```nix
# Telescope - 模糊查找工具
# 功能：文件查找、文本搜索、Git 集成等
# 快捷键：
#   <leader>ff - 查找文件
#   <leader>fg - 查找文本
#   <leader>fb - 查找 buffer
# 参考：https://github.com/nvim-telescope/telescope.nvim
plugins.telescope = {
  enable = true;
  # ...
};
```

#### 5.3.2 创建 README.md
**任务**：
- [ ] 创建 `packages/nvim/README.md`
- [ ] 说明配置结构
- [ ] 说明 lite 和 full 模式区别
- [ ] 添加使用说明
- [ ] 添加常见问题

#### 5.3.3 创建 KEYMAPS.md
**任务**：
- [ ] 创建快捷键速查表
- [ ] 按功能分类
- [ ] 添加使用示例

---

### 5.4 测试和验证

#### 5.4.1 Lite 模式测试
**任务**：
- [ ] 测试 `nix run .#nvim-lite`
- [ ] 验证只加载了基础插件
- [ ] 验证配置文件语法高亮
- [ ] 验证 telescope 基础功能
- [ ] 检查启动时间

#### 5.4.2 Full 模式测试
**任务**：
- [ ] 测试 `nix run .#nvim`
- [ ] 验证所有插件加载
- [ ] 测试 LSP 功能（跳转、重命名、格式化）
- [ ] 测试补全功能
- [ ] 测试 Git 集成
- [ ] 测试 Telescope 所有功能
- [ ] 测试调试功能
- [ ] 检查是否有错误或警告

#### 5.4.3 语言支持测试
**任务**：
- [ ] 测试 Nix LSP
- [ ] 测试 Rust LSP
- [ ] 测试 Python LSP
- [ ] 测试 Lua LSP
- [ ] 测试 C/C++ LSP
- [ ] 测试其他语言 LSP

#### 5.4.4 性能测试
**任务**：
- [ ] 测试启动时间
- [ ] 测试大文件编辑性能
- [ ] 测试补全响应速度
- [ ] 测试 LSP 响应速度

---

### 5.5 CI/CD

#### 5.5.1 添加 GitHub Actions
**任务**：
- [ ] 创建 `.github/workflows/nvim-check.yml`
- [ ] 自动测试构建 nvim 和 nvim-lite
- [ ] 检查 Nix 语法
- [ ] 运行基础测试

**示例**：
```yaml
name: Neovim Config Check
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
      - name: Build nvim
        run: nix build .#nvim
      - name: Build nvim-lite
        run: nix build .#nvim-lite
```

#### 5.5.2 添加 Pre-commit Hook
**任务**：
- [ ] 添加 pre-commit 配置
- [ ] 检查 Nix 语法
- [ ] 格式化 Nix 代码
- [ ] 检查 TODO 标记

---

### 5.6 主题和美化

#### 5.6.1 统一配色
**任务**：
- [ ] 确保所有插件使用 catppuccin 主题
- [ ] 统一边框样式（rounded）
- [ ] 统一图标风格

#### 5.6.2 优化 UI 一致性
**任务**：
- [ ] 统一浮动窗口样式
- [ ] 统一通知样式
- [ ] 统一状态栏样式

#### 5.6.3 图标配置
**任务**：
- [ ] 确保 web-devicons 正确配置
- [ ] 添加自定义图标（如果需要）
- [ ] 测试图标显示

---

## 📊 优先级总结

### 🔴 高优先级（立即执行）
1. 替换 nvim-cmp 为 blink.cmp
2. 替换 startup.nvim 为 snacks.nvim
3. **添加 Avante.nvim（AI Agent）**
4. 添加 lspsaga
5. 优化快捷键

### 🟡 中优先级（近期执行）
6. 重构目录结构
7. 迁移 snippets
8. 添加 render-markdown
9. 完善文档

### 🟢 低优先级（有时间再做）
9. 性能优化
10. CI/CD
11. 主题美化
12. 考虑替换其他插件

---

## 📝 笔记

### 已知问题
- startup.nvim 配置格式在 nixvim 中已改变，需要完全重写或替换
- treesitter 有大量不需要的 grammars，需要精简

### 设计决策
- 使用 standalone 模式而不是 home-manager module 模式
- 默认 lite 模式，full 模式需要显式指定
- **AI Agent 策略**：
  - 保留 Copilot 用于快速补全
  - 添加 Avante.nvim 用于复杂任务（重构、解释、多轮对话）
  - Claude Code 用于跨文件、架构级别的任务
  - 三者互补，各司其职

### 参考资源
- nixvim 文档：https://nix-community.github.io/nixvim/
- Neovim 插件趋势：https://dotfyle.com/neovim/plugins/trending
- 配置示例：https://github.com/nix-community/nixvim/tree/main/examples

---

## 🎯 下一步行动

1. 从高优先级任务开始
2. 每完成一个任务，更新此文档
3. 遇到问题记录在"已知问题"中
4. 重要决策记录在"设计决策"中

---

最后更新：2026-02-01

---

## 📝 更新日志

### 2026-02-01

#### ✅ 完成：替换 startup.nvim 为 alpha-nvim
- [x] 移除 snacks.nvim 的 dashboard 配置
- [x] 添加 alpha-nvim 配置
- [x] 配置 ASCII art header（青色）
- [x] 配置快捷键按钮（Find File, New File, Recent Files, Find Text, Config, Quit）
- [x] 调整布局 padding
- [ ] **待优化**：alpha-nvim 按钮缺少图标显示

**问题**：
- snacks.nvim 的 dashboard 依赖 lazy.nvim 的 `lazy.stats` 模块，在 nixvim 环境中不可用
- 使用 `preset` 配置会自动添加 lazy.nvim 统计信息

**解决方案**：
- 完全替换为 alpha-nvim，避免 lazy.nvim 依赖
- 保留 snacks.nvim 的其他功能（notifier, statuscolumn, bigfile, quickfile, words）

### 2026-01-30

#### ✅ 完成：blink.cmp 迁移
- [x] 创建 blink-cmp.nix 配置
- [x] 配置所有补全来源（LSP, Path, Snippets, Buffer）
- [x] 配置快捷键（保持与 nvim-cmp 兼容）
- [x] 配置 UI 样式（rounded 边框）
- [x] 删除所有旧的 nvim-cmp 相关文件
- [x] 删除 lsp.nix 中的 cmp.setup() 代码
- [x] 禁用 cmp-dap
- [x] 修复 copilot-chat 的 cmp 集成
- [x] 测试验证：构建成功，运行正常

**性能提升**：
- ⚡ 10-20 倍更快的补全速度
- 🦀 Rust 编写，更低延迟
- 🎯 更智能的模糊匹配

**保留的文件**：
- packages/nvim/config/plugins/cmp/blink-cmp.nix
- packages/nvim/config/plugins/cmp/autopairs.nix
- packages/nvim/config/plugins/cmp/default.nix

**删除的文件**：
- cmp.nix
- cmp-copilot.nix
- lspkind.nix
- schemastore.nix

