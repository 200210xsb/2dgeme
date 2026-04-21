# Campaign Expansion Design (10 Chapters, 1-5 Levels Each)

## Story Background

裂界战争后，世界核心被十位领主分别掌控。主角“守誓者”需要逐关夺回核心碎片，并在终局修复破碎王座。

## Main Character Equipment System

- Sword: 快速连击，适合稳定压制
- Spear: 中距离牵制，输出更平滑
- Hammer: 慢速重击，高硬直与高爆发

切换方式：战斗中可按 `Q` 切换装备。

## Chapter Structure Draft

- Chapter 1 灰烬序章：2 关（含 1 个章节 Boss）
- Chapter 2 矿井回声：3 关（含 1 个章节 Boss）
- Chapter 3 峡谷疾风：2 关（含 1 个章节 Boss）
- Chapter 4 神殿瘴雾：2 关（含 1 个章节 Boss）
- Chapter 5 镜海迷局：3 关（含 1 个章节 Boss）
- Chapter 6 雷塔轰鸣：2 关（含 1 个章节 Boss）
- Chapter 7 霜渡追猎：3 关（含 1 个章节 Boss）
- Chapter 8 永夜幕场：2 关（含 1 个章节 Boss）
- Chapter 9 星陨边界：2 关（含 1 个章节 Boss）
- Chapter 10 裂隙终焉：2 关（最终章节 Boss）

## Boss Mechanics Baseline

- Phase 1: 追击 + 普攻 + 冲刺
- Phase 2: 半血狂暴，速度与伤害提升
- Phase 2 Extra: 范围技 + 召唤小怪 + 提示信息

## Current Implementation Status

- 已完成可玩原型：单场景战斗演示
- 已接入：装备切换、Boss 二阶段、范围技、召唤小怪、受击反馈、计分
- 已接入：章节化关卡参数、关卡推进（N）、进度存档（current_stage_index/max_unlocked_stage_index）
- 下一步建议：将章节内关卡拆分为独立场景并接入章节地图、对话事件与商店系统
