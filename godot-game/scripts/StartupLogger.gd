extends Node

# 游戏启动时输出日志到文件
func _ready():
    _write_startup_log()

func _write_startup_log():
    var log_text = ""
    log_text += "=====================================\n"
    log_text += "像素斗士 Pixel Fighter v1.0 - 启动日志\n"
    log_text += "=====================================\n\n"
    log_text += "启动时间：" + str(Time.get_datetime_string_from_system()) + "\n"
    log_text += "OS 名称：" + str(OS.get_name()) + "\n"
    log_text += "Godot 版本：" + str(Engine.godot_version_string()) + "\n\n"
    
    # 检查文件
    log_text += "文件检查:\n"
    log_text += "- exe 路径：" + str(OS.get_executable_path()) + "\n"
    log_text += "- PCK 路径：" + str(ProjectSettings.globalize_path("res://")) + "\n"
    log_text += "- 运行目录：" + str(OS.get_user_data_dir()) + "\n\n"
    
    # 检查 pck 文件
    var pck_path = OS.get_executable_path().get_base_dir() + "/PixelFighter_v1.0.pck"
    if FileAccess.file_exists(pck_path):
        log_text += "✓ PCK 文件存在：" + pck_path + "\n"
    else:
        log_text += "✗ PCK 文件不存在：" + pck_path + "\n"
        log_text += "  请确保 .exe 和 .pck 在同一文件夹内！\n"
    log_text += "\n"
    
    # 系统信息
    log_text += "系统信息:\n"
    log_text += "- 屏幕分辨率：" + str(DisplayServer.screen_get_size()) + "\n"
    log_text += "- 显卡渲染器：" + str(RenderingServer.get_video_adapter_name()) + "\n"
    log_text += "- 内存：" + str(OS.get_static_memory_usage() / 1024 / 1024) + " MB\n\n"
    
    log_text += "=====================================\n"
    
    # 写入日志文件
    var log_file_path = OS.get_executable_path().get_base_dir() + "/game_log.txt"
    var file = FileAccess.open(log_file_path, FileAccess.WRITE)
    if file:
        file.store_string(log_text)
        file.close()
        print("日志已写入：", log_file_path)
    else:
        print("无法写入日志文件")
        print("日志内容：\n", log_text)
