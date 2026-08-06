extends SceneTree

const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const STORY_SCENE := preload("res://scenes/story/story_screen.tscn")
const INTERACTION_SCENE := preload("res://scenes/story/interaction_director.tscn")
const CINEMATIC_SCENE := preload("res://scenes/ui/cinematic_presenter.tscn")
const CHAPTER_END_SCENE := preload("res://scenes/ui/chapter_end_screen.tscn")

const OUTPUT_DIR := "res://reports/mvp/evidence"
const LOGICAL_SIZE := Vector2i(1920, 1080)
const HD_SIZE := Vector2i(1280, 720)
const SAMPLE_STEP := 8

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	if mkdir_error != OK:
		_fail("Could not create evidence directory: %s (error %d)" % [output_dir_absolute, mkdir_error])
		_finish()
		return

	await process_frame
	await _capture_title()
	await _capture_story_s00()
	await _capture_interaction_focus()
	await _capture_cinematic_108()
	await _capture_cinematic_9()
	await _capture_chapter_end("TRACK", "e2_chapter_end_track_1280x720.png")
	await _capture_chapter_end("PROTECT", "e2_chapter_end_protect_1280x720.png")
	await _capture_chapter_end("LOCKDOWN", "e2_chapter_end_lockdown_1280x720.png")
	_finish()


func _capture_title() -> void:
	var viewport := _make_viewport()
	var screen: Control = TITLE_SCENE.instantiate()
	viewport.add_child(screen)
	await process_frame
	screen.configure(false, false)
	await _save_capture(viewport, "e2_title_1280x720.png", HD_SIZE)
	await _release_viewport(viewport)


func _capture_story_s00() -> void:
	var viewport := _make_viewport()
	var screen: Control = STORY_SCENE.instantiate()
	viewport.add_child(screen)
	await process_frame
	screen.show_scene("S00", "관천협")
	screen.set_chapter_label("제1장 · 관천협")
	screen.show_line({
		"text_id": "CH01-S00-E2",
		"speaker_name": "이연",
		"text": "앞에 사람이 있군.",
	}, true)
	await create_timer(0.40, true, false, true).timeout
	await _save_capture(viewport, "e2_story_s00_1920x1080.png", LOGICAL_SIZE)
	await _release_viewport(viewport)


func _capture_cinematic_108() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present({
		"scene_id": "S00",
		"purpose": "길과 결과를 한 번에 고정한다.",
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": "CIN-CH01-S00-OPEN-PATH",
			"source_scene": "S00",
			"sword_count": 108,
		},
	}, "full")
	_expect(presenter.get_sword_count() == 108, "Cinematic capture must contain exactly 108 swords.")
	_expect(presenter.get_squad_count() == 12, "Cinematic capture must contain exactly 12 squads.")
	_expect(presenter.get_duplicate_slot_count() == 0, "Cinematic capture must not duplicate sword slots.")
	await _save_capture(viewport, "e2_cinematic_108_1920x1080.png", LOGICAL_SIZE)
	await _release_viewport(viewport)


func _capture_interaction_focus() -> void:
	var viewport := _make_viewport()
	var story: Control = STORY_SCENE.instantiate()
	viewport.add_child(story)
	await process_frame
	story.show_scene("S04", "청우객잔")
	story.set_chapter_label("제1장 · 객잔의 구검")
	story.show_line({
		"text_id": "CH01-S04-E2",
		"speaker_name": "이연",
		"text": "먼저 보이는 것부터 읽는다.",
	}, true)
	var dialogue_panel := story.get_node_or_null("DialoguePanel") as Control
	if dialogue_panel != null:
		dialogue_panel.hide()

	var director: InteractionDirector = INTERACTION_SCENE.instantiate()
	viewport.add_child(director)
	await process_frame
	var completion: Array[Dictionary] = []
	director.completed.connect(func(result: Dictionary) -> void: completion.append(result))
	director.start({
		"id": "INT-CH01-S04-FOCUS",
		"scene_id": "S04",
		"type": "FOCUS_POINT",
		"prompt_key": "CH01-INT-S04-FOCUS-PROMPT",
		"emotional_purpose": "객잔의 세 위협과 정보 중 이연이 먼저 읽는 단서를 선택한다.",
		"expected_duration_sec": 8.0,
		"failure_state": null,
		"alternative_input": "keyboard_or_gamepad_focus_navigation",
		"replay_behavior": "auto_complete_with_saved_first_focus_or_skip",
		"on_complete_event": "interaction_completed",
		"points": [
			{"id": "window", "label": "창문에 비친 사수의 그림자"},
			{"id": "lamp", "label": "넘어질 듯 흔들리는 등불"},
			{"id": "courier_hand", "label": "행상인의 손에서 떨어진 쪽지"},
		],
	}, {
		"prompt": "무엇을 먼저 본다",
		"settings": {"interaction_auto_complete": false},
		"replay_seen": false,
	})
	await process_frame
	await process_frame
	_expect(director.visible, "Focus interaction must remain visible before the player selects a point.")
	_expect(completion.is_empty(), "Focus interaction must not auto-complete during its E2 capture.")
	_expect(_count_visible_buttons(director) >= 2, "Focus interaction must show at least two selectable points.")
	_expect(not director.has_fail_state(), "Focus interaction must expose no fail state.")
	await _save_capture(viewport, "e2_interaction_focus_1280x720.png", HD_SIZE)
	await _release_viewport(viewport)


func _capture_cinematic_9() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present({
		"scene_id": "S05",
		"purpose": "무음검대 9검으로 객잔의 첫 공격을 제압한다.",
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": "CIN-CH01-S05-COMMON",
			"source_scene": "S05",
			"formation_template": "NINE_9",
			"sword_count": 9,
		},
	}, "full")
	_expect(presenter.get_sword_count() == 9, "S05 NINE_9 capture must contain exactly 9 swords.")
	_expect(presenter.get_squad_count() == 1, "S05 NINE_9 capture must contain exactly 1 squad.")
	_expect(presenter.get_duplicate_slot_count() == 0, "S05 NINE_9 capture must not duplicate sword slots.")
	await _save_capture(viewport, "e2_cinematic_9_1920x1080.png", LOGICAL_SIZE)
	await _release_viewport(viewport)


func _capture_chapter_end(route: String, filename: String) -> void:
	var viewport := _make_viewport()
	var screen: Control = CHAPTER_END_SCENE.instantiate()
	viewport.add_child(screen)
	await process_frame
	screen.show_completion({
		"completion_title": "제1장 완료",
		"completion_subtitle": "아홉 검을 모두 되찾았고, 북문은 아직 닫히지 않았다.",
		"choices": {"CH01-C06-PRIORITY": route},
		"flags": {"priority_choice": route, "swords_recalled": 9},
		"next_title": "다음 기록 · 백야의 북문",
	})
	await create_timer(0.38, true, false, true).timeout
	await _save_capture(viewport, filename, HD_SIZE)
	await _release_viewport(viewport)


func _make_viewport() -> SubViewport:
	var viewport := SubViewport.new()
	viewport.name = "E2CaptureViewport"
	viewport.size = LOGICAL_SIZE
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport


func _save_capture(viewport: SubViewport, filename: String, output_size: Vector2i) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame

	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("%s produced an empty viewport image." % filename)
		return
	if image.get_size() != output_size:
		image.resize(output_size.x, output_size.y, Image.INTERPOLATE_LANCZOS)

	_validate_image(filename, image, output_size)
	var absolute_path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	var save_error := image.save_png(absolute_path)
	if save_error != OK:
		_fail("%s could not be saved (error %d)." % [filename, save_error])
	else:
		print("E2_CAPTURE_SAVED %s" % absolute_path)


func _validate_image(filename: String, image: Image, expected_size: Vector2i) -> void:
	_expect(
		image.get_size() == expected_size,
		"%s has size %s; expected %s." % [filename, image.get_size(), expected_size]
	)
	if image.is_empty():
		_fail("%s is empty." % filename)
		return

	var minimum_luminance := 1.0
	var maximum_luminance := 0.0
	var luminance_sum := 0.0
	var nonblack_samples := 0
	var sample_count := 0
	var color_bins := {}
	for y in range(0, image.get_height(), SAMPLE_STEP):
		for x in range(0, image.get_width(), SAMPLE_STEP):
			var color := image.get_pixel(x, y)
			var luminance := 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
			minimum_luminance = minf(minimum_luminance, luminance)
			maximum_luminance = maxf(maximum_luminance, luminance)
			luminance_sum += luminance
			if luminance > 0.02 and color.a > 0.02:
				nonblack_samples += 1
			var color_key := (
				(int(color.r * 15.0) << 8)
				| (int(color.g * 15.0) << 4)
				| int(color.b * 15.0)
			)
			color_bins[color_key] = true
			sample_count += 1

	var average_luminance := luminance_sum / float(maxi(sample_count, 1))
	var nonblack_ratio := float(nonblack_samples) / float(maxi(sample_count, 1))
	var luminance_range := maximum_luminance - minimum_luminance
	_expect(average_luminance > 0.02, "%s is effectively black (average %.4f)." % [filename, average_luminance])
	_expect(nonblack_ratio > 0.05, "%s has too few nonblack pixels (ratio %.4f)." % [filename, nonblack_ratio])
	_expect(luminance_range > 0.04, "%s is effectively solid (luminance range %.4f)." % [filename, luminance_range])
	_expect(color_bins.size() >= 8, "%s has insufficient color variance (%d bins)." % [filename, color_bins.size()])
	print(
		"E2_CAPTURE_STATS %s size=%dx%d average=%.4f range=%.4f nonblack=%.4f bins=%d"
		% [
			filename,
			image.get_width(),
			image.get_height(),
			average_luminance,
			luminance_range,
			nonblack_ratio,
			color_bins.size(),
		]
	)


func _release_viewport(viewport: SubViewport) -> void:
	viewport.queue_free()
	await process_frame


func _count_visible_buttons(node: Node) -> int:
	var count := 1 if node is Button and (node as Button).is_visible_in_tree() else 0
	for child in node.get_children():
		count += _count_visible_buttons(child)
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	push_error("[e2-capture] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("E2_CAPTURE_PASS")
		quit(0)
		return
	for failure in _failures:
		print("E2_CAPTURE_FAILURE %s" % failure)
	print("E2_CAPTURE_FAIL")
	quit(1)
