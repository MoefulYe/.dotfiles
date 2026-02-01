# Avante.nvim 使用指南

## 配置说明

Avante.nvim 已配置为使用 Claude Sonnet 4.5 作为 AI 提供商。

### 配置文件设置（推荐）

Avante.nvim 会自动读取以下配置文件（按优先级）：

1. **项目级配置**：`$PROJECT_ROOT/.claude`（最高优先级）
2. **用户级配置**：`~/.claude`

配置文件格式（KEY=VALUE）：

```bash
# ~/.claude 或 .claude
ANTHROPIC_API_KEY=your-api-key-here
```

**优势**：
- ✅ 项目级配置可以覆盖用户级配置
- ✅ 切换目录时自动重新加载配置
- ✅ 不需要在 shell 配置中设置环境变量
- ✅ 可以为不同项目使用不同的 API Key

### 环境变量设置（备选）

如果不使用配置文件，也可以直接设置环境变量：

```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

### 配置示例

**用户级配置** (`~/.claude`)：
```bash
# 默认使用的 API Key
ANTHROPIC_API_KEY=sk-ant-xxx-default-key
```

**项目级配置** (`/path/to/project/.claude`)：
```bash
# 这个项目使用特定的 API Key
ANTHROPIC_API_KEY=sk-ant-xxx-project-specific-key
```

**注意**：
- 配置文件应该添加到 `.gitignore`，避免泄露 API Key
- 项目级配置会覆盖用户级配置

## 快捷键

### 主要功能

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>aa` | 询问 AI | 打开对话窗口，向 AI 提问 |
| `<leader>ae` | AI 编辑 | 让 AI 编辑选中的代码 |
| `<leader>ar` | 刷新建议 | 重新生成 AI 建议 |
| `<leader>at` | 切换窗口 | 显示/隐藏 AI 侧边栏 |
| `<leader>ad` | 调试信息 | 显示/隐藏调试信息 |
| `<leader>ah` | 切换提示 | 显示/隐藏提示信息 |

### 差异处理

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `co` | 使用我们的版本 | 保留当前代码 |
| `ct` | 使用 AI 的版本 | 接受 AI 建议 |
| `cb` | 使用两者 | 合并两个版本 |
| `]x` | 下一个差异 | 跳到下一个差异位置 |
| `[x` | 上一个差异 | 跳到上一个差异位置 |

### 建议操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<M-l>` | 接受建议 | 接受当前 AI 建议 |
| `<M-]>` | 下一个建议 | 查看下一个建议 |
| `<M-[>` | 上一个建议 | 查看上一个建议 |
| `<C-]>` | 忽略建议 | 忽略当前建议 |

### 导航

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `]]` | 下一个代码块 | 跳到下一个代码块 |
| `[[` | 上一个代码块 | 跳到上一个代码块 |

### 提交

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<CR>` | 提交（普通模式） | 提交当前输入 |
| `<C-s>` | 提交（插入模式） | 提交当前输入 |

## 使用场景

### 1. 代码重构

1. 选中需要重构的代码（Visual 模式）
2. 按 `<leader>ae`
3. 输入重构需求，如："重构这个函数，使用更好的错误处理"
4. 按 `<CR>` 提交
5. 查看 AI 建议，使用 `co`/`ct`/`cb` 选择版本

### 2. 代码解释

1. 选中需要解释的代码
2. 按 `<leader>aa`
3. 输入："解释这段代码的工作原理"
4. 查看 AI 的解释

### 3. 生成代码

1. 按 `<leader>aa`
2. 输入需求，如："为这个函数添加单元测试"
3. AI 会生成相应的代码

### 4. 优化代码

1. 选中代码
2. 按 `<leader>ae`
3. 输入："优化这个算法的性能"
4. 查看并应用 AI 的优化建议

## 与其他 AI 工具的分工

- **Copilot**：快速补全，单行/多行代码建议
- **Avante**：复杂任务，多轮对话，代码重构，解释说明
- **Claude Code**：跨文件操作，架构设计，大规模重构

## 配置文件位置

`packages/nvim/config/plugins/editor/avante.nix`

## 更换 AI 提供商

如果想使用其他 AI 提供商，修改配置文件中的 `provider` 字段：

```nix
provider = "openai";  # 或 "gemini", "ollama", "copilot"
```

并相应配置对应的 API 设置。

## 故障排查

### API Key 未设置

如果看到 API Key 错误，确保已设置环境变量：

```bash
echo $ANTHROPIC_API_KEY
```

### 插件未加载

检查插件是否正确加载：

```vim
:lua print(vim.inspect(require('avante')))
```

### 查看日志

```vim
:messages
```
