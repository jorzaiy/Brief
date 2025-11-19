# Git 推送指南

## 📝 当前状态

您的项目已连接到: `https://github.com/jorzaiy/Brief.git`

## 🚀 推送步骤

### 方法一：使用命令行（推荐）

#### 1. 查看修改状态
```bash
git status
```

#### 2. 添加所有修改的文件
```bash
# 添加所有文件
git add .

# 或者选择性添加
git add README.md
git add entry/src/main/ets/common/models/
git add entry/src/main/ets/common/network/
git add entry/src/main/ets/pages/
git add entry/src/main/module.json5
git add entry/src/main/resources/
```

#### 3. 提交更改
```bash
git commit -m "feat: 实现newsnow API集成和三频道新闻展示

- 更新NewsItem模型以匹配newsnow API
- 实现NewsService API调用
- 添加ChannelManager频道管理
- 重构Index页面支持三频道切换
- 优化WebView详情页
- 添加网络权限配置
- 创建README文档"
```

#### 4. 推送到远程仓库
```bash
# 推送到main分支
git push origin main

# 如果是第一次推送，可能需要设置上游分支
git push -u origin main
```

### 方法二：使用 VS Code 图形界面

1. **查看更改**
   - 点击左侧"源代码管理"图标（或按 `Ctrl+Shift+G`）
   - 查看所有修改的文件

2. **暂存更改**
   - 点击"更改"旁边的 `+` 号暂存所有文件
   - 或单独点击每个文件的 `+` 号

3. **提交**
   - 在消息框中输入提交信息
   - 点击"提交"按钮（或按 `Ctrl+Enter`）

4. **推送**
   - 点击"同步更改"或"推送"按钮
   - 或使用菜单：`...` > `推送`

## 📋 提交信息规范

建议使用以下格式：

```
<type>: <subject>

<body>
```

**Type 类型：**
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例：**
```bash
git commit -m "feat: 添加新闻聚合功能"
git commit -m "fix: 修复API地址错误"
git commit -m "docs: 更新README文档"
```

## 🔍 常用Git命令

```bash
# 查看状态
git status

# 查看修改内容
git diff

# 查看提交历史
git log --oneline

# 撤销未暂存的修改
git restore <file>

# 撤销已暂存的修改
git restore --staged <file>

# 查看远程仓库
git remote -v

# 拉取最新代码
git pull origin main

# 创建新分支
git checkout -b feature/new-feature

# 切换分支
git checkout main
```

## ⚠️ 注意事项

1. **推送前先拉取**
   ```bash
   git pull origin main
   ```
   避免冲突

2. **不要提交敏感信息**
   - API密钥
   - 密码
   - 个人信息

3. **使用 .gitignore**
   确保以下文件/目录被忽略：
   ```
   .idea/
   build/
   .hvigor/
   oh_modules/
   local.properties
   *.iml
   ```

4. **定期提交**
   - 完成一个功能就提交一次
   - 提交信息要清晰明确

## 🆘 常见问题

### 推送被拒绝
```bash
# 先拉取远程更改
git pull origin main --rebase

# 解决冲突后推送
git push origin main
```

### 忘记添加文件
```bash
# 修改最后一次提交
git add <forgotten-file>
git commit --amend --no-edit
```

### 撤销最后一次提交
```bash
# 保留修改
git reset --soft HEAD~1

# 丢弃修改
git reset --hard HEAD~1
```

## 📚 更多资源

- [Git官方文档](https://git-scm.com/doc)
- [GitHub使用指南](https://docs.github.com)
- [Git可视化学习](https://learngitbranching.js.org/)
