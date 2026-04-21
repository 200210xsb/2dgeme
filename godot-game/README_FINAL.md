# 2D 横版动作游戏 - 完整战役版

一个功能完整的 2D 横版打击游戏，包含 10 章 28 个关卡的完整战役模式。

## 游戏特色

### 🎮 核心玩法
- 流畅的移动和跳跃
- 三段连击战斗系统
- 3 种可切换武器（剑/矛/锤）
- 受击反馈（闪烁、击退、硬直）
- 屏幕震动效果

### 👹 敌人系统
- 普通敌人：巡逻、追击、攻击
- Boss 敌人：
  - 两阶段战斗（半血狂暴）
  - 冲刺攻击
  - 范围 AOE 技能
  - 召唤小怪

### 📖 战役模式
- **10 个章节**，每个章节 1-5 个关卡
- 章节主题：
  1. 灰烬序章（教学）
  2. 矿井回声
  3. 峡谷疾风
  4. 神殿瘴雾
  5. 镜海迷局
  6. 雷塔轰鸣
  7. 霜渡追猎
  8. 永夜幕场
  9. 星陨边界
  10. 裂隙终焉（最终章）

### 🛒 成长系统
- 击杀敌人获得金币
- 关卡间商店购买升级
- 升级项目：
  - ❤️ HP 上限
  - ⚔️ 攻击力
  - ⚡ 攻速
  - 🎯 暴击率
  - 💊 满血回复

### 💾 进度系统
- 自动存档
- 章节解锁机制
- 升级永久保留

## 快速开始

### Windows 测试
1. 双击运行 `Builds/Windows/SideScrollerFighter.exe`
2. 使用方向键选择章节/关卡
3. 按 Enter 开始游戏

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

### 自定义键位
编辑 `keybinds.cfg` 文件修改按键。

## 项目结构

```
godot-game/
├── scripts/
│   ├── Game.gd              # 主游戏逻辑
│   ├── Player.gd            # 玩家控制
│   ├── Enemy.gd             # 敌人 AI
│   ├── Boss.gd              # Boss AI
│   ├── CampaignData.gd      # 战役配置
│   ├── SaveData.gd          # 存档系统
│   ├── KeybindManager.gd    # 键位管理
│   ├── DropCoin.gd          # 金币掉落
│   └── CameraShake.gd       # 屏幕震动
├── scenes/
│   └── Main.tscn            # 主场景
├── Builds/
│   └── Windows/
│       ├── SideScrollerFighter.exe
│       └── SideScrollerFighter.pck
├── keybinds.cfg             # 键位配置
├── export_presets.cfg       # 导出预设
└── project.godot            # 项目配置
```

## 游戏截图与演示

游戏运行后，你将看到：
1. **开场界面**：章节/关卡选择
2. **战斗界面**：血条、分数、金币、武器、关卡信息
3. **结算界面**：胜利/失败结果
4. **商店界面**：升级购买

## 开发说明

### 技术栈
- 引擎：Godot 3.2.3
- 语言：GDScript
- 目标平台：Windows

### 导出 Windows 版本
```bash
# 使用 xvfb 进行无头导出
xvfb-run -a godot3 --path . --export "Windows Desktop" Builds/Windows/SideScrollerFighter.exe
```

### 添加新内容
1. 在 `CampaignData.gd` 中添加新关卡
2. 调整关卡参数（敌人数、HP、速度等）
3. 修改 `export_presets.cfg` 添加新导出预设

## 游戏背景

在裂界战争后，十位领主割据十域。守誓者必须穿越十章战线，逐步修复核心并终结裂隙。

## 许可证

本项目为学习演示用途。

## 版本历史

- **v1.0** (2026-04-21) - 完整战役版
  - 10 章 28 个关卡
  - Boss 战系统
  - 装备切换
  - 商店升级
  - 进度存档
