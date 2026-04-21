# Windows EXE 测试指南

## 目标

先产出一个可测试的 Windows `.exe`，验证横版移动、跳跃、攻击和敌人受击流程。

## 你需要先做的 Unity 内配置

1. 新建场景并保存为 `Assets/Scenes/Main.unity`。
2. 将以下脚本挂载到对应对象：
   - 玩家：`PlayerController2D`、`PlayerCombat`、`Health`
   - 敌人：`EnemyController2D`、`Health`
   - 输入桥：`TouchInputBridge`（桌面测试可不挂）
3. 创建 `Ground` Layer 并正确设置玩家地面检测。
4. 给玩家对象打上 `Player` Tag。
5. 将 `unity-scripts/BuildWindows.cs` 复制到 Unity 工程 `Assets/Editor/BuildWindows.cs`。

## 编辑器内快速测试

- 方向键或 A/D: 左右移动
- 空格: 跳跃
- J: 普攻连段

## 命令行打包 EXE

在你本机执行，`<UNITY_EXE_PATH>` 和 `<PROJECT_PATH>` 需要替换成你的真实路径。

```bash
# Windows PowerShell 中执行 Unity 无界面构建
"<UNITY_EXE_PATH>" -quit -batchmode -projectPath "<PROJECT_PATH>" -executeMethod BuildWindows.BuildGame -logFile "<PROJECT_PATH>/Builds/Windows/build.log"
```

## 产物路径

- EXE: `Builds/Windows/SideScrollerFighter.exe`
- 构建日志: `Builds/Windows/build.log`

## 最小验收清单

1. 游戏可启动到主场景。
2. 玩家可移动和跳跃。
3. 玩家攻击能命中敌人并扣血。
4. 敌人血量归零后销毁。
