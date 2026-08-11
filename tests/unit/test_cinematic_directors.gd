extends Node

const CINEMATIC_DIRECTOR_SCRIPT := preload(
	"res://scripts/cinematic/cinematic_director.gd"
)
const FORMATION_DIRECTOR_SCRIPT := preload(
	"res://scripts/cinematic/formation_visual_director.gd"
)

var _failures: Array[String] = []
var _cinematic_director: Node
var _completed_payloads: Array[Dictionary] = []
var _camera_cue_count := 0
var _audio_cue_count := 0
var _vfx_cue_count := 0
var _camera_cues: Array[Dictionary] = []
var _animation_cues: Array[Dictionary] = []
var _pause_states: Array[bool] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	_test_formation_counts_and_slots()
	await _test_cinematic_modes_and_result_parity()
	await _test_s09_authored_chronology()
	_finish()


func _test_formation_counts_and_slots() -> void:
	var formation: Node = FORMATION_DIRECTOR_SCRIPT.new()
	add_child(formation)

	var nine_result: Dictionary = formation.build_formation(1)
	_assert(bool(nine_result.get("ok", false)), "One-squad formation should build.")
	_assert(formation.get_squad_count() == 1, "One-squad formation should have one squad.")
	_assert(formation.get_sword_count() == 9, "One squad must render exactly 9 swords.")
	_assert(
		formation.get_squad_instance_counts() == [9],
		"One squad must contain exactly nine child instances."
	)
	_assert(
		formation.get_duplicate_slot_count() == 0,
		"Nine-sword formation must have zero duplicate slots."
	)
	_assert_unique_slot_keys(formation.get_slot_records(), 9)

	var full_result: Dictionary = formation.build_formation(12)
	_assert(bool(full_result.get("ok", false)), "Twelve-squad formation should build.")
	_assert(formation.get_squad_count() == 12, "Full formation should have 12 squads.")
	_assert(formation.get_sword_count() == 108, "Full formation must render exactly 108 swords.")
	_assert(
		formation.get_duplicate_slot_count() == 0,
		"Full formation must have zero duplicate slots."
	)

	var squad_counts: Array = formation.get_squad_instance_counts()
	_assert(squad_counts.size() == 12, "Full formation must report twelve squad counts.")
	for squad_index in range(squad_counts.size()):
		_assert(
			int(squad_counts[squad_index]) == 9,
			"Squad %d must contain exactly nine swords." % (squad_index + 1)
		)
	_assert_unique_slot_keys(formation.get_slot_records(), 108)
	_assert(formation.get_body_batch_count() == 1, "All 108 sword bodies must use one render batch.")
	_assert(
		formation.get_batched_instance_count() == 108,
		"The body MultiMesh must contain exactly 108 visible-capable instances."
	)
	_assert(formation.get_trail_pool_size() == 12, "Formation motion must reuse twelve authored trails.")

	var roles: Array = formation.get_squad_roles()
	var unique_roles: Dictionary = {}
	for role in roles:
		unique_roles[String(role)] = true
	_assert(roles.size() == 12, "Full formation should expose twelve authored roles.")
	_assert(unique_roles.size() == 12, "Each full-formation squad should have a readable role.")

	var centers: Array = formation.get_squad_centers()
	var minimum_spacing := INF
	for left_index in range(centers.size()):
		for right_index in range(left_index + 1, centers.size()):
			minimum_spacing = minf(
				minimum_spacing,
				Vector2(centers[left_index]).distance_to(Vector2(centers[right_index]))
			)
	_assert(minimum_spacing >= 200.0, "Squad centers should remain visibly separated.")

	var snapshot: Dictionary = formation.get_formation_snapshot()
	_assert(snapshot.get("authored_only") == true, "Formation must identify authored placement.")
	_assert(snapshot.get("uses_randomness") == false, "Formation must not use randomness.")
	_assert(
		snapshot.get("uses_physics_resolution") == false,
		"Formation must not use physics to decide story results."
	)
	_assert(
		snapshot.get("body_renderer") == "MultiMeshInstance2D",
		"Formation snapshot must identify the Compatibility-safe body renderer."
	)

	formation.apply_settings({
		"motion_reduction": false,
		"flash_reduction": false,
		"blade_trail_intensity": 1.0,
	})
	formation.play_motion_phase("anticipation", {"visible_blades": 108, "duration_sec": 0.0})
	var anticipation_position: Vector2 = formation.get_rendered_instance_transform(0).origin
	formation.play_motion_phase("curved_flight", {"visible_blades": 108, "duration_sec": 0.0})
	var curved_position: Vector2 = formation.get_rendered_instance_transform(0).origin
	_assert(formation.get_active_trail_count() == 12, "Full curved flight must activate twelve pooled trails.")
	formation.trigger_local_impact({"id": "FX_INTERCEPT", "squad_index": 0})
	_assert(
		formation.get_last_local_effect_position().distance_to(curved_position) < 120.0,
		"Local VFX must follow the squad's current flight position instead of its future lock point."
	)
	formation.play_motion_phase("acceleration", {"visible_blades": 108, "duration_sec": 0.0})
	var accelerated_position: Vector2 = formation.get_rendered_instance_transform(0).origin
	formation.play_motion_phase("impact", {"visible_blades": 108, "duration_sec": 0.0})
	var impact_position: Vector2 = formation.get_rendered_instance_transform(0).origin
	var normal_impact_alpha: float = formation.get_peak_local_effect_alpha()
	formation.play_motion_phase("aftermath", {"visible_blades": 108, "duration_sec": 0.0})
	var aftermath_position: Vector2 = formation.get_rendered_instance_transform(0).origin
	var final_position: Vector2 = formation.get_slot_records()[0].get("position", Vector2.ZERO)
	_assert(anticipation_position != curved_position, "Anticipation and curved flight must occupy different positions.")
	_assert(
		curved_position.distance_to(final_position) > accelerated_position.distance_to(final_position),
		"Acceleration must move a sword closer to its authored lock point."
	)
	_assert(
		impact_position.distance_to(final_position) <= 0.01 and aftermath_position.distance_to(final_position) <= 0.01,
		"Impact and aftermath must settle on the authored final slot."
	)
	_assert(
		formation.get_motion_phase_history() == [
			&"anticipation", &"curved_flight", &"acceleration", &"impact", &"aftermath"
		],
		"A sword-action beat must expose the approved five-phase grammar."
	)
	formation.apply_settings({
		"motion_reduction": false,
		"flash_reduction": false,
		"blade_trail_intensity": 0.0,
	})
	formation.play_motion_phase("curved_flight", {"visible_blades": 108, "duration_sec": 0.0})
	_assert(formation.get_active_trail_count() == 0, "Zero trail intensity must remove trail output.")
	formation.apply_settings({
		"motion_reduction": true,
		"flash_reduction": true,
		"blade_trail_intensity": 1.0,
	})
	formation.play_motion_phase("acceleration", {"visible_blades": 108, "duration_sec": 0.4})
	_assert(not formation.is_motion_animating(), "Motion reduction must avoid continuous formation animation.")
	_assert(formation.get_active_trail_count() == 0, "Motion reduction must remove moving sword trails.")
	formation.trigger_local_impact({"id": "FX_FINAL_STOP"})
	_assert(
		formation.get_peak_local_effect_alpha() < normal_impact_alpha,
		"Flash reduction must lower the actual local impact peak."
	)
	formation.set_profile("canyon_capture")
	formation.build_formation(12)
	var capture_bounds := _horizontal_slot_bounds(formation.get_slot_records())
	_assert(
		capture_bounds.x >= -360.0 and capture_bounds.y <= 500.0,
		"Canyon capture squads must stay in the road/air corridor instead of crossing human silhouettes."
	)
	formation.set_profile("north_gate_lock")
	formation.build_formation(12)
	var gate_bounds := _horizontal_slot_bounds(formation.get_slot_records())
	_assert(
		gate_bounds.x >= -360.0 and gate_bounds.y <= 360.0,
		"North-gate lock squads must stay on the door frame and preserve the character-clear corridor."
	)
	formation.queue_free()


func _test_cinematic_modes_and_result_parity() -> void:
	_cinematic_director = CINEMATIC_DIRECTOR_SCRIPT.new()
	add_child(_cinematic_director)
	_cinematic_director.completed.connect(_on_cinematic_completed)
	_cinematic_director.camera_cue_requested.connect(_on_camera_cue_requested)
	_cinematic_director.audio_cue_requested.connect(_on_audio_cue_requested)
	_cinematic_director.vfx_cue_requested.connect(_on_vfx_cue_requested)
	_cinematic_director.pause_changed.connect(func(paused: bool) -> void: _pause_states.append(paused))

	_assert(
		_cinematic_director.resolve_initial_mode(&"auto", true) == &"full",
		"First-view auto mode should resolve to full."
	)
	_assert(
		_cinematic_director.resolve_initial_mode(&"auto", false) == &"summary",
		"Caller-declared seen playback should resolve to summary."
	)

	var full_payload := await _play_and_wait(&"auto", true, 0.05)
	_assert(full_payload.get("mode") == &"full", "First view should complete in full mode.")
	_assert(_camera_cue_count > 0, "Full playback should emit camera cue events.")
	_assert(_audio_cue_count > 0, "Full playback should emit audio cue events.")
	_assert(_vfx_cue_count > 0, "Full playback should emit VFX cue events.")

	var summary_payload := await _play_and_wait(&"auto", false, 0.05)
	_assert(summary_payload.get("mode") == &"summary", "Seen playback should use summary mode.")

	var result_payload := await _play_and_wait(&"result", true, 0.0)
	_assert(result_payload.get("mode") == &"result", "Result mode should jump to result.")

	var completions_before_skip := _completed_payloads.size()
	var skip_start: Dictionary = _cinematic_director.play_from_manifest(
		_make_manifest(),
		&"TEST_CINEMATIC",
		&"full",
		true,
		1.0
	)
	_assert(bool(skip_start.get("ok", false)), "Skip fixture should start full playback.")
	var skip_returned_events: Array = _cinematic_director.skip_to_result()
	var skip_payload := await _wait_for_completion(completions_before_skip)
	_assert(skip_payload.get("mode") == &"result", "Skip should move playback to result mode.")
	_assert(skip_payload.get("skipped") == true, "Skip completion should identify the skip path.")
	_assert(
		skip_returned_events == skip_payload.get("result_events", []),
		"skip_to_result should return the same result events it emits."
	)

	var expected_events: Array = full_payload.get("result_events", [])
	for payload in [summary_payload, result_payload, skip_payload]:
		_assert(
			payload.get("result_events", []) == expected_events,
			"Full, summary, result, and skip must return identical result events."
		)

	var completions_before_pause := _completed_payloads.size()
	var pause_start: Dictionary = _cinematic_director.play_from_manifest(
		_make_manifest(),
		&"TEST_CINEMATIC",
		&"full",
		true,
		0.5
	)
	_assert(bool(pause_start.get("ok", false)), "Pause fixture should start playback.")
	_assert(_cinematic_director.set_paused(true), "Active playback should pause.")
	for _frame in range(4):
		await get_tree().process_frame
	_assert(
		_completed_payloads.size() == completions_before_pause,
		"Paused playback must not complete while time advances."
	)
	_assert(_cinematic_director.is_playing(), "Paused playback should remain active.")
	_assert(_cinematic_director.set_paused(false), "Paused playback should resume.")
	var pause_payload := await _wait_for_completion(completions_before_pause)
	_assert(
		pause_payload.get("result_events", []) == expected_events,
		"Pause and resume must preserve result events."
	)

	var completions_before_switch := _completed_payloads.size()
	var switch_start: Dictionary = _cinematic_director.play_from_manifest(
		_make_manifest(),
		&"TEST_CINEMATIC",
		&"full",
		true,
		0.2
	)
	_assert(bool(switch_start.get("ok", false)), "Summary switch fixture should start.")
	_assert(_cinematic_director.set_paused(true), "Summary switch fixture should pause first.")
	var pause_events_before_switch := _pause_states.size()
	_assert(_cinematic_director.switch_to_summary(), "Full playback should switch to summary.")
	_assert(not _cinematic_director.is_paused(), "Summary switch must clear director pause state.")
	_assert(
		_pause_states.size() == pause_events_before_switch + 1 and not _pause_states.back(),
		"Paused-to-summary switch must emit pause_changed(false)."
	)
	_assert(
		_cinematic_director.get_current_mode() == &"summary",
		"Summary switch should update current mode."
	)
	var switched_payload := await _wait_for_completion(completions_before_switch)
	_assert(switched_payload.get("mode") == &"summary", "Switched playback should complete as summary.")
	_assert(
		switched_payload.get("result_events", []) == expected_events,
		"Summary transition must preserve result events."
	)

	_assert(
		_completed_payloads.size() == 6,
		"Each of six playback paths should emit one completion signal."
	)
	_cinematic_director.queue_free()


func _test_s09_authored_chronology() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/cinematics/ch01_manifest.json")
	)
	_assert(parsed is Dictionary, "CH01 cinematic manifest must parse for chronology validation.")
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed
	var expected_phases := ["anticipation", "curved_flight", "acceleration", "impact", "aftermath"]
	for cinematic_variant in manifest.get("cinematics", []):
		var cinematic: Dictionary = cinematic_variant
		for mode in ["full", "summary"]:
			var phase_names: Array[String] = []
			for cue_variant in cinematic.get("playback", {}).get(mode, {}).get("animation_cues", []):
				phase_names.append(str(cue_variant.get("phase", "")))
			_assert(
				phase_names == expected_phases,
				"%s %s must author all five formation phases." % [cinematic.get("id", ""), mode]
			)

	_camera_cues.clear()
	_animation_cues.clear()
	var director: Node = CINEMATIC_DIRECTOR_SCRIPT.new()
	add_child(director)
	director.camera_cue_requested.connect(_on_camera_cue_requested)
	director.animation_cue_requested.connect(_on_animation_cue_requested)
	var start_result: Dictionary = director.play_from_manifest(
		manifest,
		&"CIN-CH01-S09-DEPARTURE",
		&"full",
		true,
		0.01
	)
	_assert(bool(start_result.get("ok", false)), "S09 authored chronology must start.")
	for _frame in range(120):
		if not director.is_playing():
			break
		await get_tree().process_frame
	_assert(not director.is_playing(), "S09 authored chronology should complete.")
	var shot_ids: Array[String] = []
	var first_final_index := -1
	for cue in _camera_cues:
		shot_ids.append(str(cue.get("shot_id", "")))
		if bool(cue.get("show_final_art", false)) and first_final_index < 0:
			first_final_index = shot_ids.size() - 1
	_assert(_camera_cues.size() == 10, "Explicit S09 schedule must not duplicate distributed camera cues.")
	var impact_index := shot_ids.find("S09-GATE-LOCK")
	_assert(impact_index >= 0, "S09 must include the gate-lock execution shot.")
	_assert(first_final_index > impact_index, "S09 Hero CG must appear only after gate-lock execution.")
	_assert(
		shot_ids[first_final_index] == "S09-NORTH-GATE-FINAL",
		"S09 final-shot recognition must use the explicit completed north-gate ID."
	)
	var emitted_phases: Array[String] = []
	for cue in _animation_cues:
		emitted_phases.append(str(cue.get("phase", "")))
	_assert(emitted_phases == expected_phases, "S09 runtime cues must preserve five-phase chronology.")
	director.queue_free()


func _play_and_wait(
	requested_mode: StringName,
	is_first_view: bool,
	duration_scale: float
) -> Dictionary:
	var completions_before := _completed_payloads.size()
	var start_result: Dictionary = _cinematic_director.play_from_manifest(
		_make_manifest(),
		&"TEST_CINEMATIC",
		requested_mode,
		is_first_view,
		duration_scale
	)
	_assert(bool(start_result.get("ok", false)), "Cinematic playback should start.")
	return await _wait_for_completion(completions_before)


func _wait_for_completion(completions_before: int) -> Dictionary:
	for _frame in range(240):
		if _completed_payloads.size() > completions_before:
			return _completed_payloads.back()
		await get_tree().process_frame
	_failures.append("Timed out waiting for cinematic completion signal.")
	return {}


func _make_manifest() -> Dictionary:
	return {
		"schema_version": 1,
		"default_first_view_mode": "full",
		"cinematics": [
			{
				"id": "TEST_CINEMATIC",
				"playback": {
					"full": {
						"duration_sec": 0.12,
						"shot_ids": ["WIDE", "LOCK", "AFTERMATH"],
						"audio_cues": [{"id": "LOCK_SOUND", "time_sec": 0.02}],
						"vfx_cues": [{"id": "BLADE_STOP", "time_sec": 0.04}],
					},
					"summary": {
						"duration_sec": 0.06,
						"shot_ids": ["LOCK", "AFTERMATH"],
						"audio_cues": [{"id": "SUMMARY_HIT", "time_sec": 0.01}],
						"vfx_cues": [{"id": "SUMMARY_STOP", "time_sec": 0.02}],
					},
					"result": {"duration_sec": 0.0, "apply_result_events": true},
				},
				"result_events": [
					{"flag": "refugees_safe", "operation": "set", "value": true},
					{"flag": "saw_full_108", "operation": "set", "value": true},
				],
			}
		],
	}


func _assert_unique_slot_keys(records: Array, expected_count: int) -> void:
	var unique: Dictionary = {}
	for record in records:
		unique[String(record.get("slot_key", ""))] = true
	_assert(records.size() == expected_count, "Slot record count should be %d." % expected_count)
	_assert(unique.size() == expected_count, "Every sword slot key must be unique.")


func _horizontal_slot_bounds(records: Array) -> Vector2:
	var minimum_x := INF
	var maximum_x := -INF
	for record_variant in records:
		var record: Dictionary = record_variant
		var position := Vector2(record.get("position", Vector2.ZERO))
		minimum_x = minf(minimum_x, position.x)
		maximum_x = maxf(maximum_x, position.x)
	return Vector2(minimum_x, maximum_x)


func _on_cinematic_completed(payload: Dictionary) -> void:
	_completed_payloads.append(payload.duplicate(true))


func _on_camera_cue_requested(_cue: Dictionary) -> void:
	_camera_cue_count += 1
	_camera_cues.append(_cue.duplicate(true))


func _on_animation_cue_requested(cue: Dictionary) -> void:
	_animation_cues.append(cue.duplicate(true))


func _on_audio_cue_requested(_cue: Dictionary) -> void:
	_audio_cue_count += 1


func _on_vfx_cue_requested(_cue: Dictionary) -> void:
	_vfx_cue_count += 1


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CINEMATIC_DIRECTORS_TEST_PASS")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("[cinematic-directors-test] %s" % failure)
	print("CINEMATIC_DIRECTORS_TEST_FAIL: %d failure(s)" % _failures.size())
	get_tree().quit(1)
