# 2D 横版动作游戏 - 完整战役版

本项目包含一个完整的 2D 横版打击游戏，使用 Godot 3.2.3 引擎开发，包含 10 章 28 个关卡的完整战役模式。

## 游戏特色

- 流畅的移动和跳跃
- 三段连击战斗系统
- 3 种可切换武器（剑/矛/锤）
- Boss 战（两阶段、范围技、召唤小怪）
- 10 章 28 关卡战役
- 商店升级系统
- 进度存档

## 快速测试

### Windows 版本
1. 进入 `godot-game/Builds/Windows/` 目录
2. 双击运行 `SideScrollerFighter.exe`
3. 使用默认键位进行游戏

### 默认控制
| 按键 | 功能 |
|------|------|
| A/D | 左右移动 |
| W | 跳跃 |
| J | 攻击 |
| Q | 切换武器 |
| R | 重开 |
| 1-5 | 商店购买 |
| N | 下一关 |

## 项目结构

- `godot-game/` - Godot 游戏项目（可游玩版本）
  - `scripts/` - 游戏脚本
  - `scenes/` - 游戏场景
  - `Builds/Windows/` - Windows 可执行文件
- `docs/plans/` - 设计文档
- `unity-scripts/` - Unity 版本核心脚本（参考用）

## 详细内容

查看 `godot-game/README_FINAL.md` 了解：
- 完整操作说明
- 战役章节列表
- 游戏机制详解
- 升级系统说明

## 构建说明

### Windows 导出
```bash
cd godot-game
xvfb-run -a godot3 --path . --export "Windows Desktop" Builds/Windows/SideScrollerFighter.exe
```

### 键位自定义
编辑 `godot-game/keybinds.cfg` 文件修改按键。

## 技术栈

- 引擎：Godot 3.2.3
- 语言：GDScript
- 目标平台：Windows
