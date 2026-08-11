extends SceneTree

const TitleScreenScene := preload("res://scenes/ui/title_screen.tscn")
const SettingsScreenScene := preload("res://scenes/ui/settings_screen.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_responsive_content_scale_contract()
	var title: Control = TitleScreenScene.instantiate()
	root.add_child(title)
	await process_frame
	title.configure(false, false)
	_assert(not title.is_continue_enabled(), "continue disabled without autosave")
	_assert(not title.is_manual_load_enabled(), "load disabled without manual slot")
	title.configure(true, true)
	_assert(title.is_continue_enabled(), "continue enabled with autosave")
	_assert(title.is_manual_load_enabled(), "load enabled with manual slot")
	var compact_scale := minf(844.0 / 1280.0, 390.0 / 720.0)
	var menu := title.find_child("Menu", true, false) as VBoxContainer
	_assert(menu != null, "title retains its ledger menu")
	for child: Node in menu.get_children():
		var menu_button := child as Button
		_assert(
			menu_button.custom_minimum_size.y * compact_scale >= 44.0,
			"title menu row retains a 44px target in compact landscape"
		)
	title.queue_free()

	var settings_screen: Control = SettingsScreenScene.instantiate()
	root.add_child(settings_screen)
	await process_frame
	var expected := {
		"text_scale": 1.25,
		"auto_advance_delay_sec": 1.75,
		"hold_mode": "toggle",
		"interaction_auto_complete": true,
		"cinematic_mode": "summary",
		"motion_reduction": true,
		"flash_reduction": true,
		"blade_trail_intensity": 0.4,
	}
	settings_screen.present(expected)
	var actual: Dictionary = settings_screen.collect_settings()
	for key in expected:
		_assert(actual[key] == expected[key], "settings round-trip for %s" % key)
	settings_screen.queue_free()
	print("SHELL_SCREEN_TEST_PASS")
	quit(0)


func _test_responsive_content_scale_contract() -> void:
	_assert(
		MainFlow.content_size_for_environment(Vector2i(844, 390))
			== MainFlow.COMPACT_CONTENT_SIZE,
		"small landscape selects 1280x720 content"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(1024, 600))
			== MainFlow.COMPACT_CONTENT_SIZE,
		"a narrow landscape keeps the readable compact scale"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(844, 601))
			== MainFlow.COMPACT_CONTENT_SIZE,
		"compact selection has no height-threshold gap"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(1180, 550))
			== MainFlow.COMPACT_CONTENT_SIZE,
		"compact selection has no width-threshold gap"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(390, 844))
			== MainFlow.DESKTOP_CONTENT_SIZE,
		"portrait remains outside the compact landscape contract"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(1280, 720))
			== MainFlow.DESKTOP_CONTENT_SIZE,
		"canonical 1280x720 PC/Web comparison retains 1920x1080 content"
	)
	_assert(
		MainFlow.content_size_for_environment(Vector2i(1180, 820))
			== MainFlow.DESKTOP_CONTENT_SIZE,
		"large landscape retains the desktop content scale"
	)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("SHELL_SCREEN_TEST_FAIL: %s" % message)
	quit(1)
