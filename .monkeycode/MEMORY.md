# 用户指令记忆

本文件记录了用户的指令、偏好和教导，用于在未来的交互中提供参考。

## 格式

### 用户指令条目
用户指令条目应遵循以下格式：

[用户指令摘要]
- Date: [YYYY-MM-DD]
- Context: [提及的场景或时间]
- Instructions:
  - [用户教导或指示的内容，逐行描述]

### 项目知识条目
Agent 在任务执行过程中发现的条目应遵循以下格式：

[项目知识摘要]
- Date: [YYYY-MM-DD]
- Context: Agent 在执行 [具体任务描述] 时发现
- Category: [代码结构|代码模式|代码生成|构建方法|测试方法|依赖关系|环境配置]
- Instructions:
  - [具体的知识点，逐行描述]

## 去重策略
- 添加新条目前，检查是否存在相似或相同的指令
- 若发现重复，跳过新条目或与已有条目合并
- 合并时，更新上下文或日期信息
- 这有助于避免冗余条目，保持记忆文件整洁

## 条目

[Unity 双平台 2D 游戏脚手架结构]
- Date: 2026-04-21
- Context: Agent 在执行双平台 2D 横版打击游戏初始搭建时发现
- Category: 代码结构
- Instructions:
  - 项目当前采用 docs 与 unity-scripts 分离的轻量结构，先用文档与核心脚本定义玩法骨架
  - 设计文档放在 docs/plans 下，核心脚本放在 unity-scripts 下，便于后续迁移到正式 Unity 工程

[Unity 双平台构建路径]
- Date: 2026-04-21
- Context: Agent 在执行双平台 2D 横版打击游戏初始搭建时发现
- Category: 构建方法
- Instructions:
  - 同一套 Unity 工程可先导出 Windows .exe，再切换 Android 平台导出 APK/AAB
  - 移动端通过 TouchInputBridge 适配触控输入，桌面端保留键盘输入兜底

[用户优先测试 Windows .exe]
- Date: 2026-04-21
- Context: 用户在双平台开发过程中明确提出“先做 exe 的给我测试”
- Instructions:
  - 当前阶段优先完成 Windows .exe 版本的构建与测试

[Godot3 无头导出 Windows EXE 流程]
- Date: 2026-04-21
- Context: Agent 在执行 exe 优先测试任务时发现
- Category: 构建方法
- Instructions:
  - 在无图形环境可使用 godot3-server 进行项目启动校验与导出
  - Windows 导出需放置模板到 /root/.local/share/godot/templates/3.2.3.stable
  - 导出命令可用 godot3-server --path <project> --export-debug "Windows Desktop" <output.exe>

[用户要求键位可自行修改并一次性加三项增强]
- Date: 2026-04-21
- Context: 用户提出“键位可以更改自己更改，然后加上你3条增强”
- Instructions:
  - 提供可自行修改的键位配置方式，不锁死固定按键
  - 一次交付三项增强：血条与重开、敌人追击攻击、连击与受击硬直

[Godot 项目键位自定义方案]
- Date: 2026-04-21
- Context: Agent 在实现可自行改键需求时发现
- Category: 代码模式
- Instructions:
  - 项目通过 keybinds.cfg + KeybindManager.gd 在启动时重写 InputMap
  - 键位修改无需改脚本，只需修改 keybinds.cfg 并重启游戏

[Godot 战斗反馈实现模式]
- Date: 2026-04-21
- Context: Agent 在实现 Boss、受击反馈和菜单流程时发现
- Category: 代码模式
- Instructions:
  - 受击反馈由角色脚本统一处理：闪烁、击退、硬直、信号上报 damaged
  - 屏幕震动由 CameraShake.gd 统一管理，Game.gd 通过 damaged 信号触发 trauma
  - 对局流程由 Game.gd 控制，支持开始面板与胜负结算面板

[用户要求继续添加进阶玩法]
- Date: 2026-04-21
- Context: 用户确认需要继续实现数值调优、Boss 二阶段和掉落计分
- Instructions:
  - 持续以可试玩为目标迭代战斗手感与关卡反馈系统

[用户确认继续扩展 Boss 完整二阶段玩法]
- Date: 2026-04-21
- Context: 用户对“Boss 完整两阶段机制（范围技/召唤小怪/阶段提示）”回复“需要”
- Instructions:
  - 继续实现 Boss 进阶机制并提供可直接测试的 exe 构建结果

[用户希望扩展为完整内容型游戏]
- Date: 2026-04-21
- Context: 用户提出“优化到最佳，多设计几个 boss 和 10 个关卡，并加入故事背景和装备切换”
- Instructions:
  - 项目从单场景演示升级为具备关卡与剧情规划的内容型动作游戏
  - 支持主角装备切换与多 Boss 设计

[用户修正战役规模需求]
- Date: 2026-04-21
- Context: 用户补充“不一定 10 个 Boss，但要有 10 章左右，每章 1-5 关”
- Instructions:
  - 战役结构按章节设计优先，不强制每章都设置 Boss
  - 章节内支持普通关与章节 Boss 关混合编排

[用户要求持续推进直至完成]
- Date: 2026-04-21
- Context: 用户连续要求“继续”“继续做完为止”
- Instructions:
  - 在不阻塞的前提下持续迭代实现，不等待额外确认

[用户要求不确定时先澄清]
- Date: 2026-04-21
- Context: 用户提出“Continue if you have next steps, or stop and ask for clarification if you are unsure how to proceed.”
- Instructions:
  - 若已有明确下一步则直接继续执行
  - 仅在确实不确定且无法安全默认时再提出澄清问题

[Godot 内容扩展实现方式]
- Date: 2026-04-21
- Context: Agent 在实现剧情、装备和 Boss 二阶段增强时发现
- Category: 代码结构
- Instructions:
  - 战役与剧情数据独立在 CampaignData.gd，便于后续扩展 10 关多场景
  - Player.gd 内置武器配置表并通过 switch_weapon 动作切换
  - Boss.gd 通过 phase_changed/request_spawn_minion/aoe_cast 信号与 Game.gd 解耦
