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
    echo [OK] PixelFighter_v1.0.exe 存在
) else (
    echo [ERROR] PixelFighter_v1.0.exe 不存在！
    echo 请确保 .exe 和 .pck 在同一文件夹内
    pause
    exit /b 1
)
if exist "PixelFighter_v1.0.pck" (
    echo [OK] PixelFighter_v1.0.pck 存在
) else (
    echo [ERROR] PixelFighter_v1.0.pck 不存在!
    echo 请确保 .exe 和 .pck 在同一文件夹内
    pause
    exit /b 1
)
echo.
echo [启动游戏...]
echo.
start "" "PixelFighter_v1.0.exe" > game_log.txt 2>&1
echo.
echo =====================================
echo 游戏已启动
echo 日志文件：game_log.txt
echo =====================================
timeout /t 5 /nobreak >nul
