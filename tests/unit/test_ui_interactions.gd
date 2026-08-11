extends SceneTree

var _failures: Array[String] = []
const COMPACT_SCALE := 390.0 / 720.0
const MIN_PHYSICAL_TOUCH_TARGET := 44.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await _test_story_screen()
	await _test_s02_transient_hero()
	await _test_interactions()
	await _test_consequence_screen()
	if _failures.is_empty():
		print("UI_INTERACTION_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_story_screen() -> void:
	var screen := load("res://scenes/story/story_screen.tscn").instantiate() as StoryScreen
	root.add_child(screen)
	await process_frame
	screen.show_scene("S00", "관천협")
	var compositor := screen.get_node("ShotCompositor") as VNShotCompositor
	var dialogue_panel := screen.get_node("DialoguePanel") as PanelContainer
	_expect(compositor.z_index + VNShotCompositor.MAX_INTERNAL_LAYER_Z < dialogue_panel.z_index, "Every shot layer must remain below the product dialogue UI.")
	screen.show_line({
		"text_id": "TEST-LINE",
		"speaker_id": "lee_yeon",
		"speaker_name": "이연",
		"text": "비가 오면 쇠는 무거워진다.",
	})
	_expect(not screen.is_text_fully_visible(), "Story text should begin in typing state.")
	screen.finish_typing()
	_expect(screen.is_text_fully_visible(), "Story text should support immediate display.")
	_expect(screen.get_log_entries().size() == 1, "Displayed line should enter dialogue log.")
	await _test_story_utility_tray(screen)
	var pointer_advances: Array[bool] = []
	screen.advance_requested.connect(func() -> void: pointer_advances.append(true))
	var touch_advance := InputEventScreenTouch.new()
	touch_advance.pressed = true
	screen._gui_input(touch_advance)
	_expect(pointer_advances.size() == 1, "Touching the story surface should advance fully displayed dialogue.")
	screen.show_choices({"options": [
		{"id": "A", "value": "a", "label": "지휘관을 묶는다", "description": "명령을 끊는다."},
		{"id": "B", "value": "b", "label": "길을 먼저 연다", "description": "사람을 보낸다."}
	]})
	var choice_box := screen.get_node("Choices") as VBoxContainer
	_expect(choice_box.get_child_count() == 2, "Story screen should render two narrative choices.")
	_expect(screen.get_node("DialoguePanel").size.y <= 330.0, "Dialogue panel must stay within the story-screen height budget.")
	screen.queue_free()
	await process_frame


func _test_story_utility_tray(screen: StoryScreen) -> void:
	var more_button := screen.find_child("MoreActions", true, false) as Button
	var tray := screen.get_node("UtilityTray") as PanelContainer
	var actions := tray.get_node("Actions") as HBoxContainer
	_expect(more_button != null and more_button.visible, "Story UI must retain one compact More affordance.")
	_expect(not tray.visible, "Secondary story utilities must be hidden by default.")
	_expect(actions.get_child_count() == 6, "The secondary tray must retain all six utility actions.")
	var hd_scale := 1280.0 / 1920.0
	var compact_scale := minf(844.0 / 1280.0, 390.0 / 720.0)
	_expect(
		more_button.custom_minimum_size.x * hd_scale >= 44.0
			and more_button.custom_minimum_size.y * hd_scale >= 44.0,
		"The More affordance must retain a 44px physical target at 1280x720."
	)
	_expect(
		more_button.custom_minimum_size.y * compact_scale >= 44.0,
		"The More affordance must retain a 44px physical target at 844x390 compact landscape."
	)
	var action_labels: Array[String] = []
	for child: Node in actions.get_children():
		var action := child as Button
		action_labels.append(action.text)
		_expect(not action.is_visible_in_tree(), "Tray actions must not remain visible in the primary dialogue hierarchy.")
		_expect(
			action.custom_minimum_size.x * hd_scale >= 44.0
				and action.custom_minimum_size.y * hd_scale >= 44.0,
			"Every utility action must retain a 44px physical target at 1280x720."
		)
		_expect(
			action.custom_minimum_size.y * compact_scale >= 44.0,
			"Every utility action must retain a 44px physical target at 844x390 compact landscape."
		)
	_expect(action_labels == ["기록", "자동", "스킵", "저장", "불러오기", "설정"], "The tray must preserve the approved utility order.")

	more_button.pressed.emit()
	await process_frame
	_expect(tray.visible, "Pressing More must open the secondary tray.")
	_expect(more_button.text == "닫기", "Open tray state must expose a clear close label.")
	_expect(screen.get_viewport().gui_get_focus_owner() == actions.get_child(0), "Opening the tray must focus its first action.")

	var auto_values: Array[bool] = []
	var skip_values: Array[bool] = []
	var save_events: Array[bool] = []
	var load_events: Array[bool] = []
	var settings_events: Array[bool] = []
	screen.auto_toggled.connect(func(enabled: bool) -> void: auto_values.append(enabled))
	screen.skip_toggled.connect(func(enabled: bool) -> void: skip_values.append(enabled))
	screen.save_requested.connect(func() -> void: save_events.append(true))
	screen.load_requested.connect(func() -> void: load_events.append(true))
	screen.settings_requested.connect(func() -> void: settings_events.append(true))
	(actions.get_node("자동") as Button).pressed.emit()
	(actions.get_node("스킵") as Button).pressed.emit()
	(actions.get_node("저장") as Button).pressed.emit()
	(actions.get_node("불러오기") as Button).pressed.emit()
	(actions.get_node("설정") as Button).pressed.emit()
	_expect(auto_values == [true], "Tray Auto must preserve its toggle signal.")
	_expect(skip_values == [true], "Tray Skip must preserve its toggle signal.")
	_expect(save_events.size() == 1 and load_events.size() == 1 and settings_events.size() == 1, "Tray save, load, and settings actions must preserve their signals.")
	(actions.get_node("자동") as Button).pressed.emit()
	(actions.get_node("스킵") as Button).pressed.emit()

	var cancel := InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	screen._unhandled_input(cancel)
	_expect(not tray.visible and more_button.text == "더보기", "Cancel must close the utility tray.")
	_expect(screen.get_viewport().gui_get_focus_owner() == more_button, "Closing the tray must restore focus to More.")

	more_button.pressed.emit()
	(actions.get_node("기록") as Button).pressed.emit()
	_expect(not tray.visible, "Opening the dialogue log must dismiss the utility tray.")
	_expect((screen.get_node("DialogueLog") as PanelContainer).visible, "Tray Record must preserve the dialogue-log action.")
	screen.hide_log()


func _test_s02_transient_hero() -> void:
	var screen := load("res://scenes/story/story_screen.tscn").instantiate() as StoryScreen
	root.add_child(screen)
	await process_frame
	screen.show_scene("S02", "골목의 계약")
	var compositor := screen.get_node("ShotCompositor") as VNShotCompositor
	var dialogue_panel := screen.get_node("DialoguePanel") as PanelContainer
	_expect(compositor.get_current_shot_id() == "SHOT-CH01-S02-CONTRACT", "S02 must present its authored V5 shot.")
	_expect(compositor.get_character_count() == 2, "S02 base shot must render Lee Yeon and Jo Muntak independently.")
	_expect(compositor.get_layer_count() == 2, "S02 base shot must contain exactly its two character layers.")
	_expect(
		compositor.get_resolved_background_path() == "res://assets/art/ch01-v5/CH01_ENV_ALLEY_CONTRACT_CLEAN_v001.png",
		"S02 must use the clean alley background."
	)

	var scene_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/ch01/s02.json"))
	var hero_step: Dictionary = {}
	if scene_value is Dictionary:
		for step_variant: Variant in (scene_value as Dictionary).get("steps", []):
			if step_variant is Dictionary and str((step_variant as Dictionary).get("id", "")) == "S02-010A":
				hero_step = (step_variant as Dictionary).duplicate(true)
				break
	_expect(not hero_step.is_empty(), "S02 decisive-beat story step must exist.")
	hero_step["text"] = "조문탁은 청동패를 이연의 손바닥에 눌러 넣었다."
	screen.show_line(hero_step, true)
	_expect(compositor.has_transient_hero(), "S02 decisive beat must display its transient Hero CG.")
	_expect(compositor.get_layer_count() == 3, "S02 Hero beat must add only one transient layer.")
	var hero_layer := compositor.get_node("Layers/%s" % VNShotCompositor.TRANSIENT_HERO_LAYER_ID) as TextureRect
	_expect(compositor.z_index + hero_layer.z_index < dialogue_panel.z_index, "S02 Hero CG must remain below the dialogue UI.")

	screen.show_line({"text_id": "CH01-S02-014", "speaker_id": "lee_yeon", "text": "네 번째 종 전에는 북문이 열리지 않는다."}, true)
	_expect(not compositor.has_transient_hero(), "The line after S02's decisive beat must clear the Hero CG.")
	_expect(compositor.get_layer_count() == 2, "Clearing S02 Hero CG must restore the base two-layer shot.")
	_expect(not compositor.show_transient_hero("res://assets/art/does-not-exist.png", 0.0), "A missing asset must never create a transient Hero CG.")
	_expect(not compositor.has_transient_hero(), "A rejected Hero CG asset must leave no transient layer behind.")
	screen.queue_free()
	await process_frame


func _test_interactions() -> void:
	var director := load("res://scenes/story/interaction_director.tscn").instantiate() as InteractionDirector
	root.add_child(director)
	await process_frame
	var completion: Array[Dictionary] = []
	director.completed.connect(func(result: Dictionary) -> void: completion.append(result))
	var focus := {
		"id": "TEST-FOCUS",
		"type": "FOCUS_POINT",
		"expected_duration_sec": 1.0,
		"failure_state": null,
		"points": [
			{"id": "window", "label": "창문"},
			{"id": "lamp", "label": "등불"}
		]
	}
	director.start(focus, {"settings": {"interaction_auto_complete": true}, "replay_seen": true})
	await process_frame
	_expect(completion.size() == 1, "Seen focus interaction should auto-complete on replay.")
	_expect(completion[0].get("selection") == "window", "Auto-complete should choose a deterministic focus point.")
	_expect(completion[0].get("failure") == null, "Interaction result must not contain a failure state.")

	completion.clear()
	director.apply_accessibility({"interaction_auto_complete": false})
	director.start(focus)
	await process_frame
	_expect(not director._focus_buttons.is_empty(), "Focus interaction must expose its scene targets.")
	for focus_button: Control in director._focus_buttons:
		_expect_compact_touch_target(focus_button, "Focus target")
	director.auto_complete()

	completion.clear()
	var hold := {
		"id": "TEST-HOLD",
		"type": "HOLD_INTENT",
		"expected_duration_sec": 0.05,
		"failure_state": null
	}
	director.apply_accessibility({"hold_toggle": true, "interaction_auto_complete": false})
	director.start(hold)
	await process_frame
	_expect_compact_touch_target(director._hold_button, "Hold control")
	director._toggle_active = true
	await create_timer(0.12).timeout
	_expect(completion.size() == 1, "Accessible toggle hold should complete without precision input.")
	_expect(not director.has_fail_state(), "InteractionDirector must expose no fail state.")

	completion.clear()
	var pull := {
		"id": "TEST-PULL",
		"type": "CHAIN_PULL",
		"expected_duration_sec": 1.0,
		"failure_state": null
	}
	director.start(pull)
	await process_frame
	var pull_control := director.find_child("ChainPullControl", true, false) as Button
	_expect(pull_control != null, "Chain pull must expose its primary control.")
	_expect_compact_touch_target(pull_control, "Chain-pull control")
	director.auto_complete()
	_expect(completion.size() == 1, "Chain pull must have a deterministic alternative input.")
	director.queue_free()
	await process_frame


func _test_consequence_screen() -> void:
	var consequence := load("res://scenes/ui/consequence_screen.tscn").instantiate() as ConsequenceScreen
	root.add_child(consequence)
	await process_frame
	consequence.show_result({
		"title": "수호",
		"lines": ["곽노삼과 복칠은 무사하다.", "도주자는 열린 창문으로 사라졌다.", "봉인 마차 정보를 얻었다."],
		"recall_text": "검 회수  9 / 9"
	})
	await process_frame
	_expect(consequence.visible, "Consequence screen should become visible.")
	var continue_button := consequence.find_child("Continue", true, false) as Button
	_expect(continue_button != null, "Consequence must expose its continuation control.")
	_expect_compact_touch_target(continue_button, "Consequence continuation")
	var all_text := _collect_text(consequence)
	_expect("9 / 9" in all_text, "Consequence should show blade recall state.")
	for forbidden in ["랭크", "경험치", "명성", "성공 등급"]:
		_expect(forbidden not in all_text, "Consequence must not show score language: %s" % forbidden)
	consequence.queue_free()
	await process_frame


func _collect_text(node: Node) -> String:
	var values: Array[String] = []
	if node is Label:
		values.append((node as Label).text)
	elif node is Button:
		values.append((node as Button).text)
	for child in node.get_children():
		values.append(_collect_text(child))
	return "\n".join(values)


func _expect_compact_touch_target(control: Control, label: String) -> void:
	if control == null:
		return
	_expect(
		control.size.x * COMPACT_SCALE >= MIN_PHYSICAL_TOUCH_TARGET
			and control.size.y * COMPACT_SCALE >= MIN_PHYSICAL_TOUCH_TARGET,
		"%s must retain a 44px physical target at 844x390 compact landscape." % label
	)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
