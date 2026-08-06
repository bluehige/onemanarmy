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


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	_test_formation_counts_and_slots()
	await _test_cinematic_modes_and_result_parity()
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
	formation.queue_free()


func _test_cinematic_modes_and_result_parity() -> void:
	_cinematic_director = CINEMATIC_DIRECTOR_SCRIPT.new()
	add_child(_cinematic_director)
	_cinematic_director.completed.connect(_on_cinematic_completed)
	_cinematic_director.camera_cue_requested.connect(_on_camera_cue_requested)
	_cinematic_director.audio_cue_requested.connect(_on_audio_cue_requested)
	_cinematic_director.vfx_cue_requested.connect(_on_vfx_cue_requested)

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
	_assert(_cinematic_director.switch_to_summary(), "Full playback should switch to summary.")
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


func _on_cinematic_completed(payload: Dictionary) -> void:
	_completed_payloads.append(payload.duplicate(true))


func _on_camera_cue_requested(_cue: Dictionary) -> void:
	_camera_cue_count += 1


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
