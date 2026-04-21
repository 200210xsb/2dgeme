# GitHub Release 发布指南

## 方式一：使用 GitHub CLI（推荐）

### 1. 认证 GitHub CLI
```bash
gh auth login
# 按照提示完成认证
```

### 2. 创建 Release
```bash
cd /workspace/godot-game

gh release create v1.0-FINAL-COMPLETE \
  --title "🎮 FINAL COMPLETE v1.0 - 完整正式版" \
  --notes-file RELEASE_NOTES_v1.0.md \
  ./Builds/Windows/SideScrollerFighter_FINAL_COMPLETE.exe \
  ./Builds/Windows/SideScrollerFighter_FINAL_COMPLETE.pck
```

### 3. 验证发布
访问：https://github.com/200210xsb/2dgeme/releases/tag/v1.0-FINAL-COMPLETE

---

## 方式二：手动在 GitHub 网页创建

### 步骤

1. **访问 GitHub 仓库**
   - 打开 https://github.com/200210xsb/2dgeme

2. **进入 Releases 页面**
   - 点击右侧 "Releases" 标签
   - 点击 "Create a new release"

3. **填写发布信息**
   - **Tag version**: `v1.0-FINAL-COMPLETE`
   - **Target**: `main`
   - **Release title**: `🎮 FINAL COMPLETE v1.0 - 完整正式版`

4. **编写发布说明**
   - 复制 `RELEASE_NOTES_v1.0.md` 的全部内容
   - 粘贴到发布说明文本框

5. **上传构建文件**
   - 拖拽上传以下文件：
     - `SideScrollerFighter_FINAL_COMPLETE.exe` (33MB)
     - `SideScrollerFighter_FINAL_COMPLETE.pck` (174KB)
   - 或点击 "Attach binaries" 选择文件

6. **设置完成**
   - ✅ 勾选 "Set as the latest release"
   - 点击 "Publish release"

---

## 验证发布

### 检查清单
- [ ] Release 页面可见
- [ ] 构建文件可下载
- [ ] 标签正确指向最新 commit
- [ ] 显示为 "Latest release"

### 访问链接
- **Releases**: https://github.com/200210xsb/2dgeme/releases
- **v1.0 Release**: https://github.com/200210xsb/2dgeme/releases/tag/v1.0-FINAL-COMPLETE
- **仓库首页**: https://github.com/200210xsb/2dgeme

---

## 发布后步骤

### 1. 更新 README
在 README 中添加下载链接：
```markdown
## 📦 下载

[下载最新版本 v1.0-FINAL-COMPLETE](https://github.com/200210xsb/2dgeme/releases/tag/v1.0-FINAL-COMPLETE)
- 文件大小：33MB
- 平台：Windows
```

### 2. 通知测试者
- 发送 Release 链接
- 说明操作指南
- 收集反馈

### 3. 监控问题
- 关注 Issues 标签
- 及时回复反馈
- 修复严重 bug

---

## 构建文件位置

```
/workspace/godot-game/Builds/Windows/
├── SideScrollerFighter_FINAL_COMPLETE.exe  (33MB)
└── SideScrollerFighter_FINAL_COMPLETE.pck  (174KB)
```

---

## 版本说明摘要

### 核心功能（98% 完成度）
✅ 6 种武器（剑/矛/锤/匕首/斧/弓）  
✅ 完整战斗机制（连击/暴击/格挡/弹反/冲刺）  
✅ 状态效果系统（5 种 DOT/Debuff）  
✅ 10 个独特 Boss（5 种技能）  
✅ 陷阱系统（3 种类型）  
✅ 10 章 50 关战役  

### UI 完善
✅ Boss 血条 UI  
✅ 状态效果 UI 图标  
✅ 武器专属特效  
✅ 操作提示增强  

### 操作说明
- **移动**: WASD
- **攻击**: J
- **换武器**: Q
- **格挡**: K
- **冲刺**: SPACE

---

## 常见问题

### Q: 为什么 gh auth login 失败？
A: 检查是否已安装 GitHub CLI：
```bash
# Ubuntu/Debian
sudo apt install gh

# 或使用脚本
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd -of /usr/share/keyrings/githubcli-archive-keyring.gpg
```

### Q: 上传文件失败？
A: 检查文件大小限制，GitHub Release 单个文件限制 2GB，我们的文件只有 33MB，应该没问题。

### Q: 如何更新已有 Release？
A: 在 Releases 页面点击编辑，可以修改说明和添加/删除文件。

---

**准备就绪！请执行上述步骤完成 GitHub Release 发布。** 🚀
