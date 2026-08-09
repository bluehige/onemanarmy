extends SceneTree

const RuntimeAudioPlayerScript := preload("res://scripts/audio/runtime_audio_player.gd")
const MainScene := preload("res://scenes/app/main.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var audio_player := RuntimeAudioPlayerScript.new()
	root.add_child(audio_player)
	await process_frame

	_expect(audio_player.get_cue_ids().size() == 14, "catalog should expose all 14 chapter cues")
	var required_cues := PackedStringArray([
		"AMB_RAIN_GORGE",
		"SFX_SWORD_COFFIN_WHEEL",
		"SFX_IRON_CHAIN_GRIP",
		"SFX_IRON_CHAIN_PULL",
		"SFX_SWORD_COFFIN_LOCKS_12",
		"SFX_SWORD_LAUNCH",
		"SFX_SWORD_INTERCEPT",
		"SFX_SWORD_STOP",
		"SFX_BLADE_RECALL",
		"SFX_LAMP_OUT",
		"SFX_CUP_DOWN",
		"SFX_PAPER",
		"SFX_BOW_TENSION"
	])
	var fingerprints: Dictionary = {}
	for cue_id_text in required_cues:
		var cue_id := StringName(cue_id_text)
		_expect(audio_player.has_cue(cue_id), "catalog should contain %s" % cue_id_text)
		var stream: AudioStreamWAV = audio_player.prepare_cue(cue_id)
		_expect(stream != null, "%s should synthesize an AudioStreamWAV" % cue_id_text)
		if stream != null:
			_expect(not stream.data.is_empty(), "%s should contain PCM data" % cue_id_text)
			fingerprints[hash(stream.data)] = true
	_expect(fingerprints.size() == required_cues.size(), "semantic cues should have distinct deterministic PCM")

	var cache_count := audio_player.get_cached_cue_count()
	var first_stream: AudioStreamWAV = audio_player.prepare_cue(&"SFX_CUP_DOWN")
	var second_stream: AudioStreamWAV = audio_player.prepare_cue(&"SFX_CUP_DOWN")
	_expect(first_stream == second_stream, "prepared streams should be reused from cache")
	_expect(audio_player.get_cached_cue_count() == cache_count, "cache hit should not synthesize another stream")
	var fresh_player := RuntimeAudioPlayerScript.new()
	root.add_child(fresh_player)
	await process_frame
	var fresh_stream: AudioStreamWAV = fresh_player.prepare_cue(&"SFX_CUP_DOWN")
	_expect(hash(first_stream.data) == hash(fresh_stream.data), "fresh instances should synthesize identical PCM")
	fresh_player.free()

	_expect(audio_player.play_cue(&"SFX_CUP_DOWN", {"volume_db": -4.0}), "known cue should play")
	_expect(audio_player.get_active_cue_ids().has("SFX_CUP_DOWN"), "played cue should be tracked as active")
	_expect(not audio_player.play_cue(&"UNKNOWN_CUE"), "unknown cue should fail safely")
	_expect(audio_player.stop_cue(&"SFX_CUP_DOWN"), "active cue should stop")
	_expect(not audio_player.stop_cue(&"SFX_CUP_DOWN"), "already stopped cue should report no work")

	_expect(audio_player.set_scene_ambience(&"S00"), "gorge scene should select rain ambience")
	_expect(audio_player.get_current_ambience_id() == &"AMB_RAIN_GORGE", "S00 should use gorge rain")
	_expect(audio_player.transition_scene_ambience(&"S04"), "inn scene should transition ambience")
	_expect(audio_player.get_current_ambience_id() == &"AMB_RAIN_INN", "S04 should use inn rain")
	_expect(not audio_player.transition_scene_ambience(&"UNKNOWN_SCENE"), "unknown scene should fail safely")
	audio_player.stop_all()
	_expect(audio_player.get_active_cue_ids().is_empty(), "stop_all should clear active cues")
	_expect(audio_player.get_current_ambience_id().is_empty(), "stop_all should clear ambience state")

	audio_player.free()
	await _test_main_audio_routing()
	if _failures.is_empty():
		print("RUNTIME_AUDIO_PLAYER_TEST_PASS")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _test_main_audio_routing() -> void:
	var main := MainScene.instantiate() as MainFlow
	root.add_child(main)
	await process_frame
	await process_frame
	var runtime_audio := main.get_node("RuntimeAudioPlayer") as RuntimeAudioPlayer
	var routed_cues: Array[StringName] = []
	runtime_audio.cue_played.connect(func(cue_id: StringName) -> void: routed_cues.append(cue_id))

	main.call("_on_scene_changed", {"scene_id": "S00"})
	_expect(runtime_audio.get_current_ambience_id() == &"AMB_RAIN_GORGE", "Main S00 should route gorge rain")
	_expect(routed_cues.has(&"SFX_SWORD_COFFIN_WHEEL"), "Main S00 should route the wagon-wheel cue")
	main.call("_on_scene_changed", {"scene_id": "S04"})
	_expect(runtime_audio.get_current_ambience_id() == &"AMB_RAIN_INN", "Main S04 should transition to inn rain")
	_expect(not runtime_audio.get_active_cue_ids().has("AMB_RAIN_GORGE"), "ambience transition should stop prior rain")

	main.call("_set_flow_state", "cinematic")
	main.call("_on_cinematic_audio_cue_requested", {"id": "SFX_SWORD_LAUNCH", "pitch_scale": 0.86})
	_expect(routed_cues.back() == &"SFX_SWORD_LAUNCH", "cinematic audio cue should reach RuntimeAudioPlayer")
	for interaction_route in [
		["HOLD_INTENT", &"SFX_IRON_CHAIN_GRIP"],
		["CHAIN_PULL", &"SFX_IRON_CHAIN_PULL"],
		["BLADE_RECALL", &"SFX_BLADE_RECALL"],
	]:
		main.call(
			"_on_interaction_requested",
			{
				"interaction_id": "AUDIO-ROUTE-%s" % interaction_route[0],
				"contract": {"type": interaction_route[0], "expected_duration_sec": 0.1},
			}
		)
		_expect(routed_cues.back() == interaction_route[1], "%s should route its semantic cue" % interaction_route[0])

	var child_count_before_repeat := runtime_audio.get_child_count()
	_expect(runtime_audio.play_cue(&"SFX_CUP_DOWN"), "repeat fixture cue should play")
	var child_count_after_first_play := runtime_audio.get_child_count()
	_expect(runtime_audio.play_cue(&"SFX_CUP_DOWN"), "same cue should be replayable")
	_expect(child_count_after_first_play == child_count_before_repeat + 1, "first cue play should allocate one player")
	_expect(runtime_audio.get_child_count() == child_count_after_first_play, "repeated cue should reuse its player")
	runtime_audio.stop_all()
	_expect(runtime_audio.get_active_cue_ids().is_empty(), "integrated stop_all should release active cue state")
	main.free()
