extends SceneTree

const EXPECTED_SCENES := [
	"S00", "S01", "S02", "S03", "S04", "S05", "S06", "S07A", "S07B", "S07C", "S08", "S09",
]
const MAX_EXTERNAL_WAITS := 512

var _failures: Array[String] = []
var _runtime: Node
var _registry: Node
var _signal_counts: Dictionary = {}
var _expected_error_code := ""
var _observed_expected_error := false
var _last_chapter_end_payload: Dictionary = {}


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_runtime = root.get_node_or_null("StoryRuntime")
	_registry = root.get_node_or_null("ContentRegistry")
	_assert(_runtime != null, "StoryRuntime autoload should exist.")
	_assert(_registry != null, "ContentRegistry autoload should exist.")
	if _runtime == null or _registry == null:
		_finish()
		return

	_connect_signals()
	_test_content_registry()
	_test_all_ch01_paths()
	_test_chapter_end_copy_contract()
	_test_pending_snapshot_restore()
	_test_cinematic_result_parity()
	_test_infinite_loop_guard()
	_test_required_signals()
	_finish()


func _connect_signals() -> void:
	for signal_name in [
		"scene_changed",
		"line_requested",
		"choice_requested",
		"interaction_requested",
		"cinematic_requested",
		"consequence_requested",
		"autosave_requested",
		"chapter_ended",
	]:
		_signal_counts[signal_name] = 0
		_runtime.connect(signal_name, _on_runtime_signal.bind(signal_name))
	_runtime.runtime_error.connect(_on_runtime_error)


func _test_content_registry() -> void:
	_assert(bool(_registry.call("ensure_loaded")), "ContentRegistry should load CH01 content.")
	var load_errors: Variant = _registry.call("get_load_errors")
	_assert(load_errors is Array and load_errors.is_empty(), "ContentRegistry load errors should be empty.")
	var scene_ids: Variant = _registry.call("get_scene_ids")
	_assert(scene_ids is Array and scene_ids == EXPECTED_SCENES, "ContentRegistry should expose all 12 scenes.")
	_assert(
		str(_registry.call("get_ko_text", "CH01-S00-001", "")) == "강호에는 백팔 자루의 검을 검관에 싣고 떠도는 사내가 있다는 소문이 있다.",
		"Korean text lookup should preserve the canonical line."
	)
	_assert(
		not (_registry.call("get_interaction", "INT-CH01-S00-FOCUS") as Dictionary).is_empty(),
		"Interaction lookup should resolve a known ID."
	)
	_assert(
		not (_registry.call("get_cinematic", "CIN-CH01-S00-CAPTURE") as Dictionary).is_empty(),
		"Cinematic lookup should resolve a known ID."
	)
	_assert(
		(_registry.call("get_scene", "MISSING-SCENE") as Dictionary).is_empty(),
		"Unknown scene lookup should return an empty dictionary."
	)


func _test_all_ch01_paths() -> void:
	var cold_open_options := ["CAPTURE", "OPEN_PATH"]
	var question_options := ["FACTION", "OUTSIDE", "WHY_LEE_YEON"]
	var priority_options := ["TRACK", "PROTECT", "LOCKDOWN"]
	var covered_cold_open: Dictionary = {}
	var covered_questions: Dictionary = {}
	var covered_priorities: Dictionary = {}

	for cold_open in cold_open_options:
		for question in question_options:
			for priority in priority_options:
				var final_state := _run_path(cold_open, question, priority, "full")
				_assert_path_state(final_state, cold_open, question, priority)
				covered_cold_open[cold_open] = true
				covered_questions[question] = true
				covered_priorities[priority] = true

	_assert(covered_cold_open.size() == 2, "Both S00 choices should be completed.")
	_assert(covered_questions.size() == 3, "All three S02 questions should be completed.")
	_assert(covered_priorities.size() == 3, "All three S06 final branches should be completed.")


func _test_pending_snapshot_restore() -> void:
	_assert(bool(_runtime.call("start_chapter", "CH-MVP-001")), "Snapshot fixture should start.")
	var guard := 0
	while guard < MAX_EXTERNAL_WAITS:
		guard += 1
		var state: Dictionary = _runtime.call("snapshot")
		if state.get("waiting_kind") == "choice" and state.get("pending_step", {}).get("choice_id") == "CH01-C00-PRIORITY":
			break
		_assert(_complete_current_wait(state, "CAPTURE", "FACTION", "TRACK", "full"), "Snapshot setup wait should complete.")
	var pending_snapshot: Dictionary = _runtime.call("snapshot")
	_assert(
		pending_snapshot.get("waiting_kind") == "choice",
		"Snapshot should capture the pending S00 choice."
	)
	_assert(
		bool(_runtime.call("choose", "CH01-C00-PRIORITY", "CAPTURE")),
		"Fixture should leave the captured pending choice."
	)
	_assert(bool(_runtime.call("restore", pending_snapshot)), "Pending choice snapshot should restore.")
	var restored: Dictionary = _runtime.call("snapshot")
	_assert(restored.get("waiting_kind") == "choice", "Restore should re-establish the pending choice wait.")
	_assert(
		restored.get("pending_step", {}).get("choice_id") == "CH01-C00-PRIORITY",
		"Restore should keep the exact pending choice ID."
	)
	_assert(
		not restored.get("choices", {}).has("CH01-C00-PRIORITY"),
		"Restore should roll back the choice made after the snapshot."
	)
	_assert(
		bool(_runtime.call("choose", "CH01-C00-PRIORITY", "OPEN_PATH")),
		"Restored pending choice should accept a different option."
	)
	var final_state := _complete_active_path("OPEN_PATH", "OUTSIDE", "PROTECT", "full")
	_assert_path_state(final_state, "OPEN_PATH", "OUTSIDE", "PROTECT")


func _test_chapter_end_copy_contract() -> void:
	_run_path("CAPTURE", "FACTION", "TRACK", "result")
	_assert(
		_last_chapter_end_payload.get("completion_title") == "제1장 완료",
		"Chapter end should resolve the localized completion title."
	)
	_assert(
		"강진오가 첫 번째로 돌아왔다" in str(_last_chapter_end_payload.get("completion_subtitle", "")),
		"Chapter end should carry the first restored-name payoff."
	)
	_assert(
		str(_last_chapter_end_payload.get("next_title", "")) == "다음 · 사라진 열두 번째 마차",
		"Chapter end should resolve and combine the next-record labels."
	)
	var completion_flags: Dictionary = _last_chapter_end_payload.get("flags", {})
	_assert(bool(completion_flags.get("fourth_bell_north_gate_blocked", false)), "S09 must fulfill the north-gate contract.")
	_assert(bool(completion_flags.get("refugees_admitted_side_gate", false)), "S09 must admit refugees through the side gate.")
	_assert(bool(completion_flags.get("sealed_wagons_inspected", false)), "S09 must begin individual wagon inspection.")
	_assert(bool(completion_flags.get("kang_jino_record_restored", false)), "S09 must restore Kang Jino's official record.")


func _test_cinematic_result_parity() -> void:
	var baseline := _run_path("CAPTURE", "OUTSIDE", "TRACK", "full")
	for mode in ["summary", "result", "skip"]:
		var compared := _run_path("CAPTURE", "OUTSIDE", "TRACK", mode)
		_assert(
			compared.get("flags", {}) == baseline.get("flags", {}),
			"Cinematic %s mode should produce the same flags as full mode." % mode
		)
		_assert(
			compared.get("choices", {}) == baseline.get("choices", {}),
			"Cinematic %s mode should preserve the same choices as full mode." % mode
		)


func _test_infinite_loop_guard() -> void:
	var original_scene: Dictionary = _registry.call("get_scene", "S00")
	var scene_map: Variant = _registry.get("_scenes")
	if not scene_map is Dictionary:
		_assert(false, "ContentRegistry scene map should be available to the isolated loop fixture.")
		return
	scene_map["S00"] = {
		"schema_version": 1,
		"kind": "story_scene",
		"chapter_id": "CH-MVP-001",
		"id": "S00",
		"route": "TEST",
		"steps": [{"id": "LOOP-001", "type": "jump", "target": "S00"}],
	}
	_registry.set("_scenes", scene_map)
	_expected_error_code = "INFINITE_LOOP"
	_observed_expected_error = false
	var started := bool(_runtime.call("start_chapter", "CH-MVP-001"))
	var failed_state: Dictionary = _runtime.call("snapshot")
	_assert(not started, "Infinite loop fixture should not report a successful start.")
	_assert(_observed_expected_error, "Infinite loop fixture should emit INFINITE_LOOP.")
	_assert(
		failed_state.get("last_error", {}).get("code") == "INFINITE_LOOP",
		"Infinite loop should remain visible in the runtime snapshot."
	)
	_expected_error_code = ""
	scene_map["S00"] = original_scene
	_registry.set("_scenes", scene_map)


func _test_required_signals() -> void:
	for signal_name in _signal_counts:
		_assert(int(_signal_counts[signal_name]) > 0, "Signal %s should be emitted during CH01 runs." % signal_name)


func _run_path(cold_open: String, question: String, priority: String, cinematic_mode: String) -> Dictionary:
	if not bool(_runtime.call("start_chapter", "CH-MVP-001")):
		_assert(false, "CH01 should start for %s/%s/%s." % [cold_open, question, priority])
		return _runtime.call("snapshot")
	return _complete_active_path(cold_open, question, priority, cinematic_mode)


func _complete_active_path(
	cold_open: String,
	question: String,
	priority: String,
	cinematic_mode: String
) -> Dictionary:
	var waits := 0
	while waits < MAX_EXTERNAL_WAITS:
		waits += 1
		var state: Dictionary = _runtime.call("snapshot")
		if bool(state.get("ended", false)):
			return state
		if state.get("waiting_kind") == "error":
			_assert(false, "Runtime entered an error state: %s" % state.get("last_error", {}))
			return state
		if not _complete_current_wait(state, cold_open, question, priority, cinematic_mode):
			return _runtime.call("snapshot")
	_assert(false, "CH01 exceeded %d external waits." % MAX_EXTERNAL_WAITS)
	return _runtime.call("snapshot")


func _complete_current_wait(
	state: Dictionary,
	cold_open: String,
	question: String,
	priority: String,
	cinematic_mode: String
) -> bool:
	var pending: Dictionary = state.get("pending_step", {})
	match str(state.get("waiting_kind", "")):
		"line":
			return bool(_runtime.call("advance"))
		"choice":
			var choice_id := str(pending.get("choice_id", ""))
			var option_id := ""
			match choice_id:
				"CH01-C00-PRIORITY":
					option_id = cold_open
				"CH01-C02-QUESTION":
					option_id = question
				"CH01-C06-PRIORITY":
					option_id = priority
				_:
					_assert(false, "Unexpected choice %s." % choice_id)
					return false
			return bool(_runtime.call("choose", choice_id, option_id))
		"interaction":
			var interaction_id := str(pending.get("interaction_id", ""))
			var result: Dictionary = {}
			match interaction_id:
				"INT-CH01-S00-FOCUS":
					result = {"value": "refugees"}
				"INT-CH01-S04-FOCUS":
					result = {"value": "window"}
				"INT-CH01-S08-AFTERMATH":
					match priority:
						"TRACK":
							result = {"value": "injured_innkeeper"}
						"PROTECT":
							result = {"value": "open_window"}
						"LOCKDOWN":
							result = {"value": "burned_beam"}
			return bool(_runtime.call("complete_interaction", interaction_id, result))
		"cinematic":
			return bool(
				_runtime.call("complete_cinematic", str(pending.get("cinematic_id", "")), cinematic_mode)
			)
		"consequence":
			return bool(_runtime.call("complete_consequence", str(pending.get("consequence_id", ""))))
		_:
			_assert(false, "Unexpected runtime wait state %s." % state.get("waiting_kind", ""))
			return false


func _assert_path_state(state: Dictionary, cold_open: String, question: String, priority: String) -> void:
	var label := "%s/%s/%s" % [cold_open, question, priority]
	var flags: Dictionary = state.get("flags", {})
	var choices: Dictionary = state.get("choices", {})
	_assert(bool(state.get("ended", false)), "%s should reach end_chapter." % label)
	_assert(state.get("scene_id") == "S09", "%s should finish in S09." % label)
	_assert(bool(flags.get("chapter_01_completed", false)), "%s should mark CH01 complete." % label)
	_assert(bool(flags.get("saw_full_108_deployment", false)), "%s should see all 108 swords." % label)
	_assert(bool(flags.get("swords_recalled_full", false)), "%s should recall the full deployment." % label)
	_assert(int(flags.get("swords_recalled", 0)) == 9, "%s should recall 9/9 inn swords." % label)
	_assert(choices.get("CH01-C00-PRIORITY") == cold_open, "%s should retain the S00 choice." % label)
	_assert(choices.get("CH01-C02-QUESTION") == question, "%s should retain the S02 question." % label)
	_assert(choices.get("CH01-C06-PRIORITY") == priority, "%s should retain the S06 choice." % label)
	var state_log: Variant = state.get("state_log", [])
	_assert(state_log is Array and state_log.size() == 3, "%s should log all three choices." % label)
	if state_log is Array:
		for entry in state_log:
			_assert(
				entry is Dictionary and entry.has("before") and entry.has("after"),
				"%s choice logs should retain before and after state." % label
			)

	_assert(
		bool(flags.get("cold_open_commander_captured", false)) == (cold_open == "CAPTURE"),
		"%s should match the S00 commander result." % label
	)
	_assert(flags.get("named_blade_owner_seen") == "kang_jino", "%s should remember Kang Jino's blade." % label)
	_assert(
		bool(flags.get("commander_dispatch_obtained", false)) == (cold_open == "CAPTURE"),
		"%s should preserve the captured dispatch result." % label
	)
	_assert(
		bool(flags.get("refugee_axle_broken", false)) == (cold_open == "CAPTURE"),
		"%s should preserve the refugee axle cost." % label
	)
	_assert(
		bool(flags.get("refugee_witness_present", false)) == (cold_open == "OPEN_PATH"),
		"%s should preserve the refugee witness result." % label
	)
	_assert(
		bool(flags.get("commander_warned_city", false)) == (cold_open == "OPEN_PATH"),
		"%s should preserve the commander's warning result." % label
	)
	_assert(
		flags.get("official_suspicion") == ("high" if cold_open == "CAPTURE" else "medium"),
		"%s should preserve official suspicion severity." % label
	)
	_assert(
		bool(flags.get("enemy_prepared_for_swords", false)) == (cold_open == "OPEN_PATH"),
		"%s should preserve enemy preparation knowledge." % label
	)
	_assert(bool(flags.get("entry_record_created", false)), "%s should create Lee Yeon's entry record." % label)
	_assert(bool(flags.get("jo_complicity_revealed", false)), "%s should reveal Jo Muntak's complicity." % label)
	_assert(flags.get("contract_payment") == "correction_ledger_original", "%s should retain the real contract payment." % label)
	_assert(bool(flags.get("correction_ledger_intact", false)), "%s should retain the correction original." % label)
	_assert(bool(flags.get("inn_shelters_refugees", false)), "%s should preserve the inn's refugee shelter." % label)
	_assert(bool(flags.get("gwak_accepts_known_risk", false)), "%s should preserve Gwak's accepted risk." % label)
	_assert(bool(flags.get("bokchil_family_outside_north_gate", false)), "%s should preserve Bokchil's family stake." % label)
	_assert(bool(flags.get("hongryeon_knows_ledger", false)), "%s should preserve the merchant's ledger knowledge." % label)
	_assert(bool(flags.get("common_attack_suppressed", false)), "%s should suppress the common S05 attack." % label)
	_assert(flags.get("evidence_integrity") == "threatened_but_intact", "%s should keep the original threatened but intact." % label)
	_assert(bool(flags.get("people_debt_available", false)), "%s should retain the people debt." % label)
	_assert(bool(flags.get("information_debt_available", false)), "%s should retain the information debt." % label)
	_assert(bool(flags.get("public_name_debt_available", false)), "%s should retain the public-name debt." % label)
	_assert(bool(flags.get("s06_priority_choice_unlocked", false)), "%s should unlock the S06 priority choice." % label)
	_assert(
		bool(flags.get("clue_faction_mark", false)) == (question == "FACTION"),
		"%s should match the faction question clue." % label
	)
	_assert(
		bool(flags.get("clue_lee_yeon_bait", false)) == (question == "WHY_LEE_YEON"),
		"%s should match the bait question clue." % label
	)
	_assert(
		bool(flags.get("clue_north_wagons", false)) == (question == "OUTSIDE" or priority == "PROTECT"),
		"%s should match the wagon clue sources." % label
	)

	match priority:
		"TRACK":
			_assert(flags.get("fugitive_state") == "captured", "%s should capture the fugitive." % label)
			_assert(flags.get("innkeeper_state") == "injured", "%s should injure the innkeeper." % label)
			_assert(flags.get("waiter_state") == "minor_injury", "%s should leave the waiter injured." % label)
			_assert(flags.get("inn_damage") == "minor", "%s should leave minor inn damage." % label)
			_assert(int(flags.get("north_gate_clue_level", 0)) == 2, "%s clue increment should apply once." % label)
		"PROTECT":
			_assert(flags.get("fugitive_state") == "escaped", "%s should let the fugitive escape." % label)
			_assert(flags.get("innkeeper_state") == "safe", "%s should keep the innkeeper safe." % label)
			_assert(flags.get("waiter_state") == "safe", "%s should keep the waiter safe." % label)
			_assert(flags.get("inn_damage") == "none", "%s should preserve the inn." % label)
			_assert(bool(flags.get("courier_identity_partial", false)), "%s should reveal part of Hongryeon's identity." % label)
		"LOCKDOWN":
			_assert(flags.get("fugitive_state") == "captured", "%s should capture the fugitive." % label)
			_assert(flags.get("innkeeper_state") == "safe", "%s should keep the innkeeper safe." % label)
			_assert(flags.get("waiter_state") == "minor_injury", "%s should leave the waiter injured." % label)
			_assert(flags.get("inn_damage") == "fire_damage", "%s should record fire damage." % label)
			_assert(flags.get("power_exposure") == "high", "%s should expose Lee Yeon's power." % label)


func _on_runtime_signal(_payload: Dictionary, signal_name: String) -> void:
	_signal_counts[signal_name] = int(_signal_counts.get(signal_name, 0)) + 1
	if signal_name == "chapter_ended":
		_last_chapter_end_payload = _payload.duplicate(true)


func _on_runtime_error(payload: Dictionary) -> void:
	if not _expected_error_code.is_empty() and payload.get("code") == _expected_error_code:
		_observed_expected_error = true
		return
	_failures.append("Unexpected runtime error: %s" % payload)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("STORY_RUNTIME_TEST_PASS")
		print("Completed 18 CH01 paths plus full/summary/result/skip parity.")
		quit(0)
		return
	for failure in _failures:
		push_error("[story-runtime-test] %s" % failure)
	print("STORY_RUNTIME_TEST_FAIL: %d failure(s)" % _failures.size())
	quit(1)
