extends SceneTree

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await _test_story_screen()
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
	screen.show_line({
		"text_id": "TEST-LINE",
		"speaker_name": "이연",
		"text": "비가 오면 쇠는 무거워진다."
	})
	_expect(not screen.is_text_fully_visible(), "Story text should begin in typing state.")
	screen.finish_typing()
	_expect(screen.is_text_fully_visible(), "Story text should support immediate display.")
	_expect(screen.get_log_entries().size() == 1, "Displayed line should enter dialogue log.")
	screen.show_choices({"options": [
		{"id": "A", "value": "a", "label": "지휘관을 묶는다", "description": "명령을 끊는다."},
		{"id": "B", "value": "b", "label": "길을 먼저 연다", "description": "사람을 보낸다."}
	]})
	var choice_box := screen.get_node("Choices") as VBoxContainer
	_expect(choice_box.get_child_count() == 2, "Story screen should render two narrative choices.")
	_expect(screen.get_node("DialoguePanel").size.y <= 330.0, "Dialogue panel must stay within the story-screen height budget.")
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
	var hold := {
		"id": "TEST-HOLD",
		"type": "HOLD_INTENT",
		"expected_duration_sec": 0.05,
		"failure_state": null
	}
	director.apply_accessibility({"hold_toggle": true, "interaction_auto_complete": false})
	director.start(hold)
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
	_expect(consequence.visible, "Consequence screen should become visible.")
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


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
