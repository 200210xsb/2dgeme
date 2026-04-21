extends Node

# 程序化音效生成器
var audio_bus := AudioServer.get_bus_index("Master")

# 攻击音效
func play_attack_sound() -> void:
    _play_procedural_sound(0.12, 0.8, [400, 200], 0.3)

# 受击音效
func play_hit_sound() -> void:
    _play_procedural_sound(0.08, 0.6, [150, 80], 0.4)

# Boss 受击音效
func play_boss_hit_sound() -> void:
    _play_procedural_sound(0.15, 0.5, [120, 60], 0.5)

# 金币拾取音效
func play_coin_sound() -> void:
    _play_procedural_sound(0.1, 0.7, [600, 900], 0.25, "square")

# 升级购买音效
func play_upgrade_sound() -> void:
    _play_procedural_sound(0.2, 0.6, [400, 600, 800], 0.3, "sine")

# 死亡音效
func play_death_sound() -> void:
    _play_procedural_sound(0.3, 0.5, [300, 100], 0.4)

# Boss 狂暴音效
func play_enraged_sound() -> void:
    _play_procedural_sound(0.5, 0.8, [100, 50, 200], 0.6, "sawtooth")

# 程序化生成音效
func _play_procedural_sound(duration: float, volume: float, freqs: Array, type: String = "square") -> void:
    var stream = AudioStreamGenerator.new()
    stream.mix_rate = 44100
    stream.buffer_length = 0.3
    
    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = db_to_lin(volume)
    player.bus = "Master"
    add_child(player)
    
    var data = stream.get_data()
    var samples = data.data
    
    var samples_to_write = int(44100.0 * duration)
    var sample_index = 0
    
    for freq in freqs:
        var freq_duration = int(samples_to_write / freqs.size())
        for i in range(freq_duration):
            if sample_index >= samples.size():
                break
            
            var t = float(i) / 44100.0
            var sample = 0.0
            
            if type == "square":
                sample = 0.5 if sin(2 * PI * freq * t) > 0 else -0.5
            elif type == "sine":
                sample = sin(2 * PI * freq * t)
            elif type == "sawtooth":
                sample = 2.0 * (t * freq - floor(0.5 + t * freq))
            else:
                sample = sin(2 * PI * freq * t)
            
            # ADSR 包络
            var envelope = 1.0
            var total = freq_duration
            if i < total * 0.1:  # Attack
                envelope = float(i) / (total * 0.1)
            elif i > total * 0.8:  # Release
                envelope = 1.0 - float(i - total * 0.8) / (total * 0.2)
            
            samples[sample_index] = Vector2(sample * envelope, sample * envelope)
            sample_index += 1
    
    data.data = samples
    stream.set_data(data)
    player.play()
    
    # 自动清理
    yield(player, "finished")
    player.queue_free()
