extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var snapshot := {
		"snapshot_version": 1,
		"chapter_id": "CH-MVP-001",
		"scene_id": "S07B",
		"flags": {
			"priority_choice": "protect",
			"innkeeper_state": "safe",
			"clue_north_wagons": true,
		},
		"choices": {"CH01-C06-PRIORITY": "PROTECT"},
		"ended": false,
	}
	var document := RuntimeSaveAdapter.make_slot_document(snapshot, "manual_01")
	_assert(document["slot_id"] == "manual_01", "Adapter should preserve target slot ID.")
	_assert(document["route"] == "PROTECT", "Adapter should expose the final route.")
	_assert(document["character_states"]["innkeeper"] == "safe", "Adapter should expose character state.")
	_assert(document["evidence"]["north_wagons"], "Adapter should expose evidence state.")
	_assert(not document.has("seen_text_ids"), "Global seen state must never enter a slot.")
	_assert(RuntimeSaveAdapter.has_restorable_snapshot(document), "Adapter should recognize a valid runtime snapshot.")
	_assert(RuntimeSaveAdapter.extract_runtime_snapshot(document) == snapshot, "Adapter should round-trip the runtime snapshot.")
	print("RUNTIME_SAVE_ADAPTER_TEST_PASS" if _failures.is_empty() else "RUNTIME_SAVE_ADAPTER_TEST_FAIL")
	if not _failures.is_empty():
		for failure in _failures:
			push_error("[runtime-save-adapter-test] %s" % failure)
	quit(0 if _failures.is_empty() else 1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
