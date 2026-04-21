@echo off
chcp 65001 >nul
echo =====================================
echo 像素斗士 Pixel Fighter v1.0
echo 启动日志
echo =====================================
echo.
echo [启动时间] %date% %time%
echo [运行目录] %CD%
echo.
echo [检查文件]
if exist "PixelFighter_v1.0.exe" (
    echo ✓ PixelFighter_v1.0.exe 存在
) else (
    echo ✗ PixelFighter_v1.0.exe 不存在！
)
if exist "PixelFighter_v1.0.pck" (
    echo ✓ PixelFighter_v1.0.pck 存在
) else (
    echo ✗ PixelFighter_v1.0.pck 不存在！
)
echo.
echo [启动游戏...]
echo.
PixelFighter_v1.0.exe > game_log.txt 2>&1
echo.
echo =====================================
echo 游戏已关闭
echo 详细日志请查看：game_log.txt
echo =====================================
pause
