extends SceneTree

const MainScene := preload("res://scenes/app/main.tscn")
const MAX_FLOW_STEPS := 700

var _failures: Array[String] = []
var _main: MainFlow
var _save_service: Node
var _app_state: Node
var _test_root := ""
var _consequence_routes: Dictionary = {}


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	_save_service = root.get_node_or_null("SaveService")
	_app_state = root.get_node_or_null("AppState")
	_assert(_save_service != null, "SaveService autoload should exist.")
	_assert(_app_state != null, "AppState autoload should exist.")
	if _save_service == null or _app_state == null:
		_finish()
		return

	_test_root = OS.get_temp_dir().path_join("onemanarmy_main_flow_%d" % OS.get_process_id())
	_assert(bool(_save_service.call("set_storage_root", _test_root).get("ok", false)), "Temp save root should be accepted.")
	_cleanup_save_files()
	_app_state.call("reset_slot_state", "autosave")
	_app_state.call("reset_global_state")

	_main = MainScene.instantiate() as MainFlow
	root.add_child(_main)
	await process_frame
	await process_frame

	_test_scene_contract_and_title()
	await _test_unseen_skip_and_device_inputs()
	await _test_cinematic_controls()
	await _test_pending_manual_save_restore()
	_test_global_slot_separation()
	await _test_all_eighteen_routes()
	await _test_seen_skip_and_auto_timer()
	await _test_continue_and_fatal_error()

	_main.queue_free()
	await process_frame
	_cleanup_save_files()
	_finish()


func _test_scene_contract_and_title() -> void:
	_assert(_main.get_flow_state() == "title", "Main should boot to the title screen.")
	_assert(_main.get_node_or_null("SceneStack") is Node, "Main/SceneStack must remain a Node.")
	_assert(_main.get_node_or_null("CinematicStage") is Node3D, "Main/CinematicStage must remain Node3D.")
	_assert(_main.get_node_or_null("UILayer") is CanvasLayer, "Main/UILayer must remain CanvasLayer.")
	var title := _main.get_node("UILayer/TitleScreen") as TitleScreen
	_assert(not title.is_continue_enabled(), "Continue should be disabled before an autosave exists.")
	_assert(not title.is_manual_load_enabled(), "Load should be disabled before a manual save exists.")
	_assert(_action_has_keyboard("advance_dialogue"), "Dialogue advance needs a keyboard binding.")
	_assert(_action_has_mouse("advance_dialogue"), "Dialogue advance needs a mouse binding.")
	_assert(_action_has_gamepad("advance_dialogue"), "Dialogue advance needs a gamepad binding.")


func _test_unseen_skip_and_device_inputs() -> void:
	_assert(_main.start_new_game(), "New Game should start CH-MVP-001.")
	_assert(_main.get_flow_state() == "story", "New Game should enter StoryScreen.")
	var initial := _main.get_runtime_snapshot()
	var initial_step_id := str(initial.get("pending_step", {}).get("id", ""))
	var initial_text_id := _main.get_active_line_id()
	_assert(not initial_text_id.is_empty(), "The first line should expose a text ID.")
	_assert(not _global_values("seen_text_ids").has(initial_text_id), "The first fixture line should begin unseen.")

	var skip_key := InputEventKey.new()
	skip_key.keycode = KEY_S
	skip_key.physical_keycode = KEY_S
	skip_key.pressed = true
	(_main.get_node("UILayer/StoryScreen") as StoryScreen)._unhandled_input(skip_key)
	await process_frame
	await process_frame
	_assert(
		str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", "")) == initial_step_id,
		"Skip must never advance an unseen line."
	)

	var mouse_advance := InputEventMouseButton.new()
	mouse_advance.button_index = MOUSE_BUTTON_LEFT
	mouse_advance.pressed = true
	(_main.get_node("UILayer/StoryScreen") as StoryScreen)._unhandled_input(mouse_advance)
	await process_frame
	_assert(_main.is_active_line_fully_visible(), "Mouse advance should finish typing first.")
	_assert(
		str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", "")) == initial_step_id,
		"Finishing unseen typing must not auto-advance."
	)
	_assert(_global_values("seen_text_ids").has(initial_text_id), "A fully displayed line should become globally seen.")

	var gamepad_advance := InputEventJoypadButton.new()
	gamepad_advance.button_index = JOY_BUTTON_A
	gamepad_advance.pressed = true
	(_main.get_node("UILayer/StoryScreen") as StoryScreen)._unhandled_input(gamepad_advance)
	await process_frame
	_assert(
		str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", "")) != initial_step_id,
		"Gamepad confirm should advance a fully displayed line."
	)
	(_main.get_node("UILayer/StoryScreen") as StoryScreen)._unhandled_input(skip_key)


func _test_cinematic_controls() -> void:
	await _drive_until("cinematic", "", "CAPTURE", "FACTION", "TRACK")
	_assert(_main.get_flow_state() == "cinematic", "S00 should reach the first cinematic.")
	_assert(_main.get_cinematic_mode() == "full", "Default cinematic mode should be full.")
	_assert(_main.get_presented_sword_count() == 108, "S00 presenter should show exactly 108 swords.")
	_assert(_main.get_presented_duplicate_slot_count() == 0, "S00 formation must have no duplicate slots.")
	var presenter := _main.get_node("UILayer/CinematicPresenter") as CinematicPresenter
	presenter.pause_requested.emit()
	_assert(_main.is_cinematic_paused(), "Cinematic pause intent should pause playback.")
	presenter.pause_requested.emit()
	_assert(not _main.is_cinematic_paused(), "A second pause intent should resume playback.")
	presenter.summary_requested.emit()
	_assert(_main.get_cinematic_mode() == "summary", "Summary intent should switch modes.")
	presenter.skip_requested.emit()
	await process_frame
	_assert(_main.get_flow_state() != "cinematic", "Skip intent should return narrative control.")
	_assert(_global_values("seen_cinematic_ids").has("CIN-CH01-S00-CAPTURE"), "Completed cinematic should become globally seen.")


func _test_pending_manual_save_restore() -> void:
	await _drive_until("choice", "CH01-C06-PRIORITY", "CAPTURE", "FACTION", "TRACK")
	_assert(_main.get_flow_state() == "choice", "Fixture should reach the pending S06 choice.")
	_assert(_main.save_game(), "Manual save should accept a pending choice snapshot.")
	var saved_snapshot := _main.get_runtime_snapshot()
	_assert(saved_snapshot.get("pending_step", {}).get("choice_id") == "CH01-C06-PRIORITY", "Manual snapshot should preserve S06 choice.")
	_assert(_main.select_choice("TRACK"), "Fixture should be able to leave the saved choice.")
	_assert(_main.load_game(), "Manual load should restore the saved pending choice.")
	var restored := _main.get_runtime_snapshot()
	_assert(restored.get("waiting_kind") == "choice", "Manual load should restore choice wait state.")
	_assert(restored.get("pending_step", {}).get("choice_id") == "CH01-C06-PRIORITY", "Manual load should restore the exact pending choice ID.")
	_assert(not restored.get("choices", {}).has("CH01-C06-PRIORITY"), "Choice made after save must be rolled back.")

	_main.show_settings()
	var settings: Dictionary = _global_state().get("settings", {}).duplicate(true)
	settings["auto_advance_delay_sec"] = 0.1
	settings["hold_mode"] = "toggle"
	settings["cinematic_mode"] = "result"
	settings["interaction_auto_complete"] = false
	_main.apply_settings(settings)
	_assert(_main.get_flow_state() == "choice", "Closing settings should return to the pending choice.")
	_assert(not (_main.get_node("UILayer/SettingsScreen") as SettingsScreen).visible, "Applied settings should close the overlay.")


func _test_global_slot_separation() -> void:
	var manual_result: Dictionary = _save_service.call("load_manual_slot")
	var global_result: Dictionary = _save_service.call("load_global")
	_assert(bool(manual_result.get("ok", false)), "Manual slot should load after main-flow save.")
	_assert(bool(global_result.get("ok", false)), "Global state should load after seen-state writes.")
	var slot: Dictionary = manual_result.get("data", {})
	for global_key in ["seen_text_ids", "seen_cinematic_ids", "completed_interaction_ids", "settings"]:
		_assert(not slot.has(global_key), "Slot must not contain global field %s." % global_key)
	_assert(slot.has("runtime_snapshot"), "Slot envelope should retain the StoryRuntime snapshot.")
	var global: Dictionary = global_result.get("data", {})
	_assert(global.get("settings", {}).get("hold_mode") == "toggle", "Settings should persist only in global state.")
	_assert(not global.get("seen_text_ids", []).is_empty(), "Seen text should persist globally.")
	_assert(not global.get("completed_interaction_ids", []).is_empty(), "Completed interactions should persist globally.")


func _test_all_eighteen_routes() -> void:
	var route_count := 0
	for cold_open in ["CAPTURE", "OPEN_PATH"]:
		for question in ["FACTION", "OUTSIDE", "WHY_LEE_YEON"]:
			for priority in ["TRACK", "PROTECT", "LOCKDOWN"]:
				_assert(_main.start_new_game(), "Route %s/%s/%s should start." % [cold_open, question, priority])
				var final_state := await _complete_route(cold_open, question, priority)
				_assert_route_result(final_state, cold_open, question, priority)
				route_count += 1
				_main.return_to_title()
				await process_frame
	_assert(route_count == 18, "All 18 CH01 route combinations should complete.")
	_assert(_consequence_routes.size() == 3, "All three consequence variants should be presented.")
	var completed := _global_values("completed_interaction_ids")
	_assert(completed.size() == 8, "All eight CH01 interactions used by the story should be globally completed.")


func _test_seen_skip_and_auto_timer() -> void:
	_assert(_main.start_new_game(), "Seen-skip fixture should start.")
	var first_step := str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", ""))
	_main.set_skip_mode(true)
	await process_frame
	await process_frame
	_assert(
		str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", "")) != first_step,
		"Read-text skip should advance a globally seen line."
	)
	_main.set_skip_mode(false)
	_main.return_to_title()

	_assert(_main.start_new_game(), "Auto-timer fixture should start.")
	var auto_step := str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", ""))
	_main.set_auto_mode(true)
	_main.advance_story()
	await create_timer(0.18).timeout
	_assert(
		str(_main.get_runtime_snapshot().get("pending_step", {}).get("id", "")) != auto_step,
		"Auto mode should advance after the configured timer."
	)
	_main.set_auto_mode(false)
	_main.return_to_title()


func _test_continue_and_fatal_error() -> void:
	_assert(bool(_save_service.call("has_autosave")), "Integrated flow should produce an autosave.")
	_assert(_main.continue_game(), "Continue should restore the latest autosave.")
	_assert(_main.get_flow_state() == "chapter_end", "Completed autosave should reopen the chapter-end screen.")
	var chapter_end := _main.get_node("UILayer/ChapterEndScreen") as ChapterEndScreen
	_assert("제1장 완료" in chapter_end.get_display_text(), "Chapter-end screen should show completion copy.")
	chapter_end.title_requested.emit()
	_assert(_main.get_flow_state() == "title", "Chapter-end title intent should return to TitleScreen.")

	_main.call("_on_runtime_error", {"code": "TEST_FATAL", "message": "fixture", "fatal": true})
	_assert(_main.get_flow_state() == "fatal_error", "Fatal runtime errors should open an error UI.")
	_assert((_main.get_node("UILayer/FatalErrorOverlay") as Control).visible, "Fatal error overlay should be visible.")
	_assert(_main.get_last_error().get("code") == "TEST_FATAL", "Fatal payload should remain inspectable.")
	_main.return_to_title()


func _drive_until(
	target_flow: String,
	target_choice_id: String,
	cold_open: String,
	question: String,
	priority: String
) -> void:
	for _step in MAX_FLOW_STEPS:
		if _main.get_flow_state() == target_flow:
			if target_flow != "choice" or _pending_choice_id() == target_choice_id:
				return
		await _advance_current_flow(cold_open, question, priority)
	_assert(false, "Flow did not reach %s/%s." % [target_flow, target_choice_id])


func _complete_route(cold_open: String, question: String, priority: String) -> Dictionary:
	for _step in MAX_FLOW_STEPS:
		if _main.get_flow_state() == "chapter_end":
			return _main.get_runtime_snapshot()
		await _advance_current_flow(cold_open, question, priority)
	_assert(false, "Route %s/%s/%s exceeded flow guard." % [cold_open, question, priority])
	return _main.get_runtime_snapshot()


func _advance_current_flow(cold_open: String, question: String, priority: String) -> void:
	match _main.get_flow_state():
		"story":
			_main.advance_story()
			_main.advance_story()
		"choice":
			var choice_id := _pending_choice_id()
			var option_id := ""
			match choice_id:
				"CH01-C00-PRIORITY":
					option_id = cold_open
				"CH01-C02-QUESTION":
					option_id = question
				"CH01-C06-PRIORITY":
					option_id = priority
			_assert(not option_id.is_empty(), "Unexpected choice %s." % choice_id)
			if not option_id.is_empty():
				_main.select_choice(option_id)
		"interaction":
			_main.complete_active_interaction()
		"cinematic":
			_main.skip_active_cinematic()
		"consequence":
			var consequence := _main.get_node("UILayer/ConsequenceScreen") as ConsequenceScreen
			var display_text := _collect_text(consequence)
			_assert("9 / 9" in display_text, "Consequence should show 9/9 blade recall.")
			for forbidden in ["성공 등급", "랭크", "경험치"]:
				_assert(forbidden not in display_text, "Consequence must not show %s." % forbidden)
			_consequence_routes[_route_from_snapshot()] = true
			_main.continue_consequence()
		"fatal_error":
			_assert(false, "Main flow entered fatal error: %s" % _main.get_last_error())
		_:
			_assert(false, "Unexpected main flow state: %s" % _main.get_flow_state())
	await process_frame


func _assert_route_result(state: Dictionary, cold_open: String, question: String, priority: String) -> void:
	var label := "%s/%s/%s" % [cold_open, question, priority]
	var flags: Dictionary = state.get("flags", {})
	var choices: Dictionary = state.get("choices", {})
	_assert(bool(state.get("ended", false)), "%s should reach chapter end." % label)
	_assert(choices.get("CH01-C00-PRIORITY") == cold_open, "%s should retain S00 choice." % label)
	_assert(choices.get("CH01-C02-QUESTION") == question, "%s should retain S02 choice." % label)
	_assert(choices.get("CH01-C06-PRIORITY") == priority, "%s should retain S06 choice." % label)
	_assert(int(flags.get("swords_recalled", 0)) == 9, "%s should recall 9/9 swords." % label)
	_assert(bool(flags.get("chapter_01_completed", false)), "%s should mark CH01 complete." % label)
	match priority:
		"TRACK":
			_assert(flags.get("fugitive_state") == "captured", "%s track result should capture fugitive." % label)
			_assert(flags.get("innkeeper_state") == "injured", "%s track result should retain injury." % label)
		"PROTECT":
			_assert(flags.get("fugitive_state") == "escaped", "%s protect result should release fugitive." % label)
			_assert(flags.get("innkeeper_state") == "safe", "%s protect result should keep people safe." % label)
		"LOCKDOWN":
			_assert(flags.get("inn_damage") == "fire_damage", "%s lockdown result should retain fire damage." % label)
			_assert(flags.get("power_exposure") == "high", "%s lockdown result should expose power." % label)


func _pending_choice_id() -> String:
	return str(_main.get_runtime_snapshot().get("pending_step", {}).get("choice_id", ""))


func _route_from_snapshot() -> String:
	return str(_main.get_runtime_snapshot().get("flags", {}).get("priority_choice", "")).to_upper()


func _global_state() -> Dictionary:
	var value: Variant = _app_state.get("global_state")
	return value.duplicate(true) if value is Dictionary else {}


func _global_values(key: String) -> Array:
	var value: Variant = _global_state().get(key, [])
	return value.duplicate() if value is Array else []


func _action_has_keyboard(action: StringName) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return true
	return false


func _action_has_mouse(action: StringName) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton:
			return true
	return false


func _action_has_gamepad(action: StringName) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return true
	return false


func _collect_text(node: Node) -> String:
	var values: Array[String] = []
	if node is Label:
		values.append((node as Label).text)
	elif node is Button:
		values.append((node as Button).text)
	for child in node.get_children():
		values.append(_collect_text(child))
	return "\n".join(values)


func _cleanup_save_files() -> void:
	if _save_service == null or _test_root.is_empty():
		return
	var paths: Array[String] = [
		str(_save_service.call("get_slot_path", "autosave")),
		str(_save_service.call("get_slot_path", "manual_01")),
		str(_save_service.call("get_global_path")),
	]
	for base_path in paths:
		for suffix in ["", ".bak", ".tmp", ".restore.tmp"]:
			var target := "%s%s" % [base_path, suffix]
			if FileAccess.file_exists(target):
				DirAccess.remove_absolute(target)
	if DirAccess.dir_exists_absolute(_test_root):
		DirAccess.remove_absolute(_test_root)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MAIN_FLOW_TEST_PASS")
		print("Completed device input checks, pending save/restore, and all 18 CH01 routes.")
		quit(0)
		return
	for failure in _failures:
		push_error("[main-flow-test] %s" % failure)
	print("MAIN_FLOW_TEST_FAIL: %d failure(s)" % _failures.size())
	quit(1)
