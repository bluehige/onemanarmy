extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var state := root.get_node_or_null("AppState")
	_assert(state != null, "AppState autoload should exist.")
	if state == null:
		_finish()
		return

	state.reset_global_state()
	_assert(not state.is_text_seen("LINE-A"), "Fresh global state should not mark a line seen.")
	_assert(state.mark_text_seen("LINE-A"), "First line mark should change global state.")
	_assert(not state.mark_text_seen("LINE-A"), "Repeated line mark should not duplicate the ID.")
	_assert(state.is_text_seen("LINE-A"), "Marked line should be queryable.")
	_assert(state.global_state["seen_text_ids"].size() == 1, "Seen line IDs should remain unique.")

	_assert(state.mark_cinematic_seen("CIN-A"), "First cinematic mark should change state.")
	_assert(state.is_cinematic_seen("CIN-A"), "Marked cinematic should be queryable.")
	_assert(state.mark_interaction_completed("INT-A"), "First interaction mark should change state.")
	_assert(state.is_interaction_completed("INT-A"), "Completed interaction should be queryable.")
	_assert(not state.mark_text_seen(""), "Empty IDs should be rejected.")

	var updated: Dictionary = state.update_settings({
		"text_scale": 1.25,
		"hold_mode": "toggle",
		"unknown_key": "ignored",
	})
	_assert(updated["text_scale"] == 1.25, "Known setting should update.")
	_assert(updated["hold_mode"] == "toggle", "Known enum setting should update.")
	_assert(not updated.has("unknown_key"), "Unknown setting should not enter global state.")
	for key in state.DEFAULT_SETTINGS:
		_assert(updated.has(key), "Updated settings should retain default key %s." % key)

	state.reset_global_state()
	_finish()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("APP_STATE_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[app-state-test] %s" % failure)
	quit(1)
