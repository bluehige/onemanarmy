extends Node
class_name RuntimeAudioPlayer

signal cue_played(cue_id: StringName)
signal cue_stopped(cue_id: StringName)
signal ambience_changed(scene_id: StringName, cue_id: StringName)

const DEFAULT_CATALOG_PATH := "res://data/audio/ch01_cues.json"
const TAU_F := TAU

var _cue_definitions: Dictionary = {}
var _scene_ambience: Dictionary = {}
var _stream_cache: Dictionary = {}
var _players: Dictionary = {}
var _active_cues: Dictionary = {}
var _current_ambience_id := StringName()
var _current_ambience_scene := StringName()


func _ready() -> void:
	if _cue_definitions.is_empty():
		load_catalog(DEFAULT_CATALOG_PATH)


func load_catalog(path: String = DEFAULT_CATALOG_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var catalog: Dictionary = parsed
	var cues: Variant = catalog.get("cues", {})
	var ambience: Variant = catalog.get("scene_ambience", {})
	if typeof(cues) != TYPE_DICTIONARY or typeof(ambience) != TYPE_DICTIONARY:
		return false
	stop_all()
	_cue_definitions = (cues as Dictionary).duplicate(true)
	_scene_ambience = (ambience as Dictionary).duplicate(true)
	_stream_cache.clear()
	return not _cue_definitions.is_empty()


func has_cue(cue_id: StringName) -> bool:
	return _cue_definitions.has(String(cue_id))


func get_cue_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for cue_key: Variant in _cue_definitions.keys():
		result.append(String(cue_key))
	result.sort()
	return result


func prepare_cue(cue_id: StringName) -> AudioStreamWAV:
	var cue_key := String(cue_id)
	if _stream_cache.has(cue_key):
		return _stream_cache[cue_key] as AudioStreamWAV
	if not _cue_definitions.has(cue_key):
		return null
	var definition: Dictionary = _cue_definitions[cue_key]
	var stream := _synthesize_stream(definition)
	if stream == null:
		return null
	_stream_cache[cue_key] = stream
	return stream


func play_cue(cue_id: StringName, options: Dictionary = {}) -> bool:
	if cue_id.is_empty():
		return false
	var cue_key := String(cue_id)
	var stream := prepare_cue(cue_id)
	if stream == null:
		return false
	var player: AudioStreamPlayer = _players.get(cue_key) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = "Cue_%s" % cue_key.to_lower()
		add_child(player)
		player.finished.connect(_on_player_finished.bind(cue_key))
		_players[cue_key] = player
	var definition: Dictionary = _cue_definitions[cue_key]
	player.stream = stream
	player.volume_db = float(options.get("volume_db", definition.get("volume_db", 0.0)))
	player.pitch_scale = clampf(float(options.get("pitch_scale", 1.0)), 0.05, 4.0)
	player.bus = StringName(String(options.get("bus", "Master")))
	if DisplayServer.get_name() != "headless" and (bool(options.get("restart", true)) or not player.playing):
		player.play()
	_active_cues[cue_key] = true
	cue_played.emit(cue_id)
	return true


func stop_cue(cue_id: StringName) -> bool:
	var cue_key := String(cue_id)
	if not _players.has(cue_key) or not _active_cues.has(cue_key):
		return false
	var player: AudioStreamPlayer = _players[cue_key]
	player.stop()
	_active_cues.erase(cue_key)
	if _current_ambience_id == cue_id:
		_current_ambience_id = StringName()
		_current_ambience_scene = StringName()
	cue_stopped.emit(cue_id)
	return true


func stop_all() -> void:
	for player_value: Variant in _players.values():
		var player := player_value as AudioStreamPlayer
		if player != null:
			player.stop()
	_active_cues.clear()
	_current_ambience_id = StringName()
	_current_ambience_scene = StringName()


func set_scene_ambience(scene_id: StringName, options: Dictionary = {}) -> bool:
	return transition_scene_ambience(scene_id, options)


func transition_scene_ambience(scene_id: StringName, options: Dictionary = {}) -> bool:
	var scene_key := String(scene_id)
	if not _scene_ambience.has(scene_key):
		return false
	var next_cue := StringName(String(_scene_ambience[scene_key]))
	if next_cue.is_empty() or not has_cue(next_cue):
		return false
	if _current_ambience_id == next_cue and _active_cues.has(String(next_cue)):
		var keep_options := options.duplicate(true)
		keep_options["restart"] = false
		play_cue(next_cue, keep_options)
		_current_ambience_scene = scene_id
		ambience_changed.emit(scene_id, next_cue)
		return true
	if not _current_ambience_id.is_empty():
		stop_cue(_current_ambience_id)
	if not play_cue(next_cue, options):
		return false
	_current_ambience_id = next_cue
	_current_ambience_scene = scene_id
	ambience_changed.emit(scene_id, next_cue)
	return true


func get_current_ambience_id() -> StringName:
	return _current_ambience_id


func get_current_ambience_scene() -> StringName:
	return _current_ambience_scene


func get_cached_cue_count() -> int:
	return _stream_cache.size()


func get_active_cue_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for cue_key: Variant in _active_cues.keys():
		result.append(String(cue_key))
	result.sort()
	return result


func _on_player_finished(cue_key: String) -> void:
	_active_cues.erase(cue_key)
	if String(_current_ambience_id) == cue_key:
		_current_ambience_id = StringName()
		_current_ambience_scene = StringName()


func _synthesize_stream(definition: Dictionary) -> AudioStreamWAV:
	var duration := clampf(float(definition.get("duration", 0.25)), 0.04, 4.0)
	var sample_rate := clampi(int(definition.get("sample_rate", 22050)), 8000, 48000)
	var frame_count := maxi(1, int(ceil(duration * sample_rate)))
	var pcm := PackedByteArray()
	pcm.resize(frame_count * 2)
	var gain := clampf(float(definition.get("gain", 0.55)), 0.0, 0.95)
	var seed := int(definition.get("seed", 1))
	for frame in frame_count:
		var time := float(frame) / float(sample_rate)
		var sample := _sample_for_kind(definition, time, frame, duration, seed)
		var sample_int := int(round(clampf(sample * gain, -0.98, 0.98) * 32767.0))
		var encoded := sample_int & 0xffff
		pcm[frame * 2] = encoded & 0xff
		pcm[frame * 2 + 1] = (encoded >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = pcm
	if bool(definition.get("loop", false)):
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = frame_count
	return stream


func _sample_for_kind(definition: Dictionary, time: float, frame: int, duration: float, seed: int) -> float:
	var kind := String(definition.get("kind", "impact"))
	var mode := String(definition.get("mode", ""))
	var noise := _deterministic_noise(frame, seed)
	match kind:
		"rain":
			var bed := noise * 0.42 + _deterministic_noise(frame / 5, seed + 17) * 0.28
			var drop_phase := fmod(time * 7.0 + float(seed) * 0.071, 1.0)
			var drop := sin(TAU_F * (1600.0 + float(seed % 5) * 110.0) * time) * exp(-drop_phase * 55.0) if drop_phase < 0.12 else 0.0
			return bed * 0.72 + drop * 0.32
		"wagon":
			var rumble := sin(TAU_F * 48.0 * time) * 0.35 + noise * 0.18
			var wheel_phase := fmod(time, 0.31)
			var clack := (noise * 0.55 + sin(TAU_F * 510.0 * time) * 0.45) * exp(-wheel_phase * 42.0)
			return (rumble + clack * 0.9) * _edge_envelope(time, duration, 0.02, 0.08)
		"chain":
			var interval := 0.12 if mode == "pull" else 0.055
			var local_time := fmod(time, interval)
			var metallic := sin(TAU_F * float(definition.get("frequency", 920.0)) * time)
			metallic += sin(TAU_F * float(definition.get("frequency_2", 1430.0)) * time) * 0.52
			var scrape := noise * (0.42 if mode == "pull" else 0.18)
			return (metallic * exp(-local_time * (17.0 if mode == "pull" else 48.0)) + scrape) * _edge_envelope(time, duration, 0.004, 0.09)
		"locks":
			var pulse_count := maxi(1, int(definition.get("pulse_count", 12)))
			var interval := duration / float(pulse_count)
			var pulse_index := mini(pulse_count - 1, int(time / interval))
			var pulse_time := fmod(time, interval)
			var lock_tone := sin(TAU_F * (980.0 + float(pulse_index % 3) * 170.0) * time)
			return (lock_tone * 0.7 + noise * 0.3) * exp(-pulse_time * 58.0)
		"sword":
			return _sword_sample(mode, time, frame, duration, seed)
		"lamp":
			var lamp_env := _edge_envelope(time, duration, 0.002, duration * 0.72)
			var pop := sin(TAU_F * 150.0 * time) * exp(-time * 38.0)
			return (noise * 0.62 + pop * 0.55) * lamp_env
		"impact":
			var impact_frequency := float(definition.get("frequency", 360.0))
			var impact := sin(TAU_F * impact_frequency * time) + sin(TAU_F * impact_frequency * 1.51 * time) * 0.35
			return (impact * 0.7 + noise * 0.3) * exp(-time * float(definition.get("decay", 18.0)))
		"paper":
			var movement := 0.38 + 0.62 * absf(sin(TAU_F * 5.2 * time))
			return noise * movement * _edge_envelope(time, duration, 0.03, 0.11)
		"bow":
			var progress := clampf(time / duration, 0.0, 1.0)
			var creak_frequency := lerpf(74.0, 126.0, progress)
			var creak := sin(TAU_F * creak_frequency * time + sin(time * 39.0) * 0.4)
			var fibers := noise * (0.12 + progress * 0.19)
			return (creak * 0.72 + fibers) * _edge_envelope(time, duration, 0.08, 0.08)
	return noise * _edge_envelope(time, duration, 0.01, 0.05)


func _sword_sample(mode: String, time: float, frame: int, duration: float, seed: int) -> float:
	var progress := clampf(time / duration, 0.0, 1.0)
	var noise := _deterministic_noise(frame, seed)
	match mode:
		"launch":
			var launch_frequency := lerpf(180.0, 1550.0, progress)
			return (sin(TAU_F * launch_frequency * time) * 0.65 + noise * 0.35) * _edge_envelope(time, duration, 0.008, 0.06)
		"intercept":
			var ring := sin(TAU_F * 1180.0 * time) + sin(TAU_F * 1730.0 * time) * 0.58
			return (ring * 0.62 + noise * 0.38) * exp(-time * 10.5)
		"stop":
			var stop_frequency := lerpf(1150.0, 92.0, progress)
			return (sin(TAU_F * stop_frequency * time) * 0.72 + noise * 0.2) * _edge_envelope(time, duration, 0.002, duration * 0.84)
		"recall":
			var recall_frequency := lerpf(1380.0, 260.0, progress)
			var flutter := sin(TAU_F * recall_frequency * time + sin(time * 62.0) * 0.7)
			return (flutter * 0.72 + noise * 0.28) * _edge_envelope(time, duration, 0.015, 0.07)
	return noise * exp(-time * 12.0)


func _deterministic_noise(frame: int, seed: int) -> float:
	var value := (frame * 1103515245 + seed * 12345 + (frame % 97) * 2654435761) & 0x7fffffff
	return float(value) / 1073741823.5 - 1.0


func _edge_envelope(time: float, duration: float, attack: float, release: float) -> float:
	var attack_gain := clampf(time / maxf(attack, 0.0001), 0.0, 1.0)
	var release_gain := clampf((duration - time) / maxf(release, 0.0001), 0.0, 1.0)
	return attack_gain * release_gain
