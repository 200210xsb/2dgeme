# Combat Feel Update v2 - 打击感完善

## 版本信息
- **版本号**: ULTIMATE v2
- **导出时间**: 2026-04-21
- **文件大小**: 33MB
- **构建文件**: `SideScrollerFighter_ULTIMATE_v2.exe`

## 新增打击感系统

### 1. 命中停顿 (Hit Stop)
**文件**: `scripts/HitStopManager.gd`

当攻击命中敌人时，游戏会短暂暂停（80ms），产生强烈的打击反馈。
- **玩家攻击命中**: 0.08 秒停顿
- **敌人受击**: 0.04 秒停顿
- **Boss 受击**: 0.06 秒停顿

### 2. 输入缓冲 (Input Buffer)
**文件**: `scripts/InputBuffer.gd`

在攻击动作结束前输入的攻击指令会被缓存，动作结束后立即执行。
- **缓冲窗口**: 0.15 秒
- **效果**: 连招更流畅，避免输入丢失

### 3. 打击特效系统
**文件**: `scripts/HitEffects.gd`

多种视觉效果增强打击反馈：
- **火花 (Spark)**: 金属碰撞效果
- **血迹 (Blood)**: 击中生物敌人
- **冲击波 (Impact)**: 重型攻击
- **斩击 (Slash)**: 快速挥砍轨迹

### 4. 战斗流畅度优化
**文件**: `scripts/CombatFlow.gd`

#### 4.1 攻击取消窗口
- 攻击动作的前 60% 时间内可以取消
- 允许更灵活的连招组合

#### 4.2 冲刺系统
- **冲刺速度**: 520.0（双倍移动速度）
- **冲刺时间**: 0.12 秒
- **冷却时间**: 0.28 秒
- **操作**: 默认 Dash 键（待配置）

#### 4.3 移动优化
- 加速度：1200.0
- 减速度：800.0
- 使用 Lerping 平滑加速/减速

## 整合到的核心文件

### Player.gd 改动
```gdscript
# 新增变量
var attack_cancelable := false
var cancel_window_timer := 0.0
var dash_enabled := false
var dash_cooldown_timer := 0.0
var is_dashing := false

# 优化移动
velocity.x = lerp(velocity.x, axis * MOVE_SPEED, 0.25)  # 平滑加速
velocity.x = lerp(velocity.x, 0.0, 0.15)  # 平滑减速

# 输入缓冲攻击
elif input_buffer_ref != null:
    var buffered = input_buffer_ref.check_and_consume("attack")
    if buffered:
        _attack()

# 冲刺功能
if dash_enabled and Input.is_action_just_pressed("dash"):
    _perform_dash()
```

### Game.gd 改动
```gdscript
# 初始化 InputBuffer
var input_buffer = get_node_or_null("InputBuffer")
if input_buffer != null:
    player.input_buffer_ref = input_buffer

# 攻击命中触发特效和停顿
body.take_damage(player.current_attack_damage, player.global_position, 250.0)
hit_stop_manager.trigger_hit_stop(0.08)
hit_effects.spawn_hit_effect(effect_type, hit_position)
```

### Enemy.gd 改动
```gdscript
# 受击时生成血迹特效
hit_effects.spawn_hit_effect("blood", global_position)
hit_stop_manager.trigger_hit_stop(0.04)
```

### Boss.gd 改动
```gdscript
# Boss 受击特效更丰富
var effect_type = ["spark", "spark", "impact"].pick_random()
hit_effects.spawn_hit_effect(effect_type, global_position)
hit_stop_manager.trigger_hit_stop(0.06)
```

### Main.tscn 改动
新增场景节点：
- `HitStopManager` - 全局命中停顿管理器
- `InputBuffer` - 输入缓冲系统
- `HitEffects` - 打击特效生成器

## 操作说明

### 基础操作
| 按键 | 功能 |
|------|------|
| A/D | 左右移动 |
| W | 跳跃 |
| J | 攻击 |
| K | 切换武器 |

### 新增操作（待配置键位）
| 按键 | 功能 |
|------|------|
| Dash 键 | 冲刺闪避 |

## 打击感设计原则

### 3C 原则
1. **Character（角色）** - 清晰的视觉反馈
2. **Camera（镜头）** - 屏幕震动配合
3. **Control（控制）** - 响应迅速的输入

### 打击反馈层次
1. **命中前** - 攻击预警、动作前摇
2. **命中时** - 命中停顿、特效生成、音效播放
3. **命中后** - 击退效果、伤害数字、敌人硬直

### 时间参数
| 效果 | 持续时间 |
|------|----------|
| 攻击命中停顿 | 0.08s |
| 敌人受击停顿 | 0.04s |
| Boss 受击停顿 | 0.06s |
| 输入缓冲窗口 | 0.15s |
| 攻击取消窗口 | 攻击时长的 60% |
| 冲刺持续时间 | 0.12s |
| 冲刺冷却 | 0.28s |

## 测试建议

### 打击感测试
1. **连续攻击** - 体验连招流畅度
2. **移动攻击** - 测试移动中攻击手感
3. **对不同敌人** - 小怪、精英、Boss 的反馈差异
4. **不同武器** - 剑/矛/锤的打击感区别

### 流畅度测试
1. **快速变向** - 左右移动切换
2. **跳跃攻击** - 空中连招
3. **输入缓冲** - 快速连续输入命令
4. **取消测试** - 攻击后摇取消

## 已知问题

1. 冲刺键位尚未配置到默认键位绑定
2. 打击特效在低帧率下可能简化
3. 需要进一步调整 hit stop 时长以适配困难难度

## 下一步优化计划

- [ ] 添加武器专属特效（剑光/锤震/矛刺）
- [ ] 命中停顿时长随伤害变化
- [ ] 受击音效分层（轻击/重击/暴击）
- * [ ] 敌人受击动画混合
- [ ] 连击数影响 hit stop 时长
- [ ] 屏幕震动强度随打击力度变化

## 文件清单

### 新增文件
- `scripts/HitStopManager.gd`
- `scripts/InputBuffer.gd`
- `scripts/HitEffects.gd`
- `scripts/CombatFlow.gd`
- `COMBAT_FEEL_GUIDE.md`
- `COMBAT_FEEL_UPDATE_v2.md`

### 修改文件
- `scripts/Player.gd`
- `scripts/Game.gd`
- `scripts/Enemy.gd`
- `scripts/Boss.gd`
- `scenes/Main.tscn`

### 导出版本
- `Builds/Windows/SideScrollerFighter_ULTIMATE_v2.exe` (33MB)
- `Builds/Windows/SideScrollerFighter_ULTIMATE_v2.pck` (149KB)

---

**打击感完善完成度**: 85%
**下一步重点**: 武器特效差异化 + 受击动画混合
