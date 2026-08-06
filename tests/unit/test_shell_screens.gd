extends SceneTree

const TitleScreenScene := preload("res://scenes/ui/title_screen.tscn")
const SettingsScreenScene := preload("res://scenes/ui/settings_screen.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var title: Control = TitleScreenScene.instantiate()
	root.add_child(title)
	await process_frame
	title.configure(false, false)
	_assert(not title.is_continue_enabled(), "continue disabled without autosave")
	_assert(not title.is_manual_load_enabled(), "load disabled without manual slot")
	title.configure(true, true)
	_assert(title.is_continue_enabled(), "continue enabled with autosave")
	_assert(title.is_manual_load_enabled(), "load enabled with manual slot")
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


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("SHELL_SCREEN_TEST_FAIL: %s" % message)
	quit(1)
