# Godot Windows EXE 快速测试

这个目录是可直接导出 Windows `.exe` 的最小 2D 横版打击 Demo。

## 已完成内容

- 键位可自定义：读取 `keybinds.cfg`，你可自行改按键
- 增强 1：血条 UI 与死亡后按 `R` 重开
- 增强 2：敌人追击、近战攻击与冷却
- 增强 3：玩家 3 段连击与受击硬直
- 新增 Boss：普通攻击 + 冲刺技能
- Boss 二阶段：半血狂暴，移速与输出提升
- Boss 二阶段增强：范围技 + 召唤小怪 + 阶段提示
- 新增打击反馈：受击闪烁、击退、屏幕震动
- 新增流程界面：开始菜单、胜利/失败结算
- 新增掉落与计分：敌人死亡掉落金币并累计分数
- 新增装备切换：战斗中切换 Sword/Spear/Hammer
- 新增战役实装框架：约 10 章节，每章 1-5 关卡参数与推进逻辑
- 章节内可存在普通关（无 Boss）与 Boss 关（章节节点战）
- 新增开场章节/关卡选择：方向键选择，Enter 进入
- 新增章节战线总览：开场显示 10 章解锁与通关状态（C/U/L）
- 新增成长扩展：商店支持 Attack Speed 与 Crit 升级
- 导出预设：`export_presets.cfg`（Windows Desktop）

## 本环境构建结果

- `Builds/Windows/SideScrollerFighter.exe`
- `Builds/Windows/SideScrollerFighter.pck`

## 本机测试方式（Windows）

1. 拿到整个 `godot-game` 目录。
2. 双击运行 `Builds/Windows/SideScrollerFighter.exe`。
3. 按键测试（默认）：
   - `Arrow Left/Right`：切换章节（开场）
   - `Arrow Up/Down`：切换章节内关卡（开场）
   - `Enter`：开始
   - `A`：左移
   - `D`：右移
   - `W`：跳跃
   - `S`：开场菜单向下选择关卡
   - `J`：攻击
   - `Q`：切换装备
   - `1`：商店购买 HP 升级
   - `2`：商店购买攻击升级
   - `3`：商店满血回复
   - `4`：商店购买攻速升级
   - `5`：商店购买暴击升级
   - `N`：通关后进入下一关卡
   - `R`：重开
4. 击败敌人后拾取金币提升 `Score`，全清后显示结算分数。

## 进度存档

- 进度文件：`user://campaign_save.json`
- 存档内容：当前关卡索引、已解锁/已通关进度、金币与升级等级

## 改键位

直接修改 `keybinds.cfg`，例如：

```ini
[keys]
ui_left="Left"
ui_right="Right"
ui_up="Up"
ui_down="Down"
attack="K"
switch_weapon="E"
restart="P"
shop_buy_hp="Z"
shop_buy_attack="X"
shop_buy_heal="C"
shop_buy_speed="V"
shop_buy_crit="B"
```

保存后重新启动游戏即可生效。
