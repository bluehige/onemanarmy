extends SceneTree

const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const STORY_SCENE := preload("res://scenes/story/story_screen.tscn")
const INTERACTION_SCENE := preload("res://scenes/story/interaction_director.tscn")
const CINEMATIC_SCENE := preload("res://scenes/ui/cinematic_presenter.tscn")
const CONSEQUENCE_SCENE := preload("res://scenes/ui/consequence_screen.tscn")
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
	await _capture_interaction_focus_s00()
	await _capture_interaction_focus_s04()
	await _capture_cinematic_108(
		"CIN-CH01-S00-CAPTURE",
		"e2_cinematic_108_capture_1920x1080.png",
		"e2_cinematic_108_capture_reveal_1920x1080.png",
		"지휘관과 명령선을 한 번에 고립한다."
	)
	await _capture_cinematic_108(
		"CIN-CH01-S00-OPEN-PATH",
		"e2_cinematic_108_open_path_1920x1080.png",
		"e2_cinematic_108_open_path_reveal_1920x1080.png",
		"피란민이 빠져나갈 길을 먼저 연다.",
		"e2_cinematic_108_1920x1080.png"
	)
	await _capture_cinematic_9()
	await _capture_cinematic_north_gate()
	await _capture_consequence("TRACK", "res://assets/art/ch01-redesign-v2/CH01_AFTERMATH_TRACK_v002.png", "e2_consequence_track_v4_1280x720.png")
	await _capture_consequence("PROTECT", "res://assets/art/ch01-redesign-v2/CH01_AFTERMATH_PROTECT_v002.png", "e2_consequence_protect_v4_1280x720.png")
	await _capture_consequence("LOCKDOWN", "res://assets/art/ch01-redesign-v2/CH01_AFTERMATH_LOCKDOWN_v002.png", "e2_consequence_lockdown_v4_1280x720.png")
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
		"text_id": "CH01-S00-001",
		"speaker_name": "",
		"text": "검관 맨 뒤, 가장 낮은 잠금쇠에 한 자루가 비스듬히 고정돼 있었다. 금 간 황동 코등이에는 강진오 세 글자가 남아 있었다.",
	}, true)
	await create_timer(0.40, true, false, true).timeout
	await _save_capture(viewport, "e2_story_s00_1920x1080.png", LOGICAL_SIZE)
	await _save_capture(viewport, "e2_story_s00_1280x720.png", HD_SIZE)
	await _release_viewport(viewport)


func _capture_cinematic_108(
	cinematic_id: String,
	filename: String,
	reveal_filename: String,
	purpose: String,
	legacy_filename: String = ""
) -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present({
		"scene_id": "S00",
		"purpose": purpose,
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": cinematic_id,
			"source_scene": "S00",
			"sword_count": 108,
		},
	}, "full")
	presenter.apply_camera_cue({"shot_id": "S00-12-CUT"})
	_expect(presenter.get_visible_sword_count() == 108, "Authored reveal must expose all 108 slots.")
	await _save_capture(viewport, reveal_filename, LOGICAL_SIZE)
	presenter.show_final_state()
	_expect(presenter.get_sword_count() == 108, "Cinematic capture must contain exactly 108 swords.")
	_expect(presenter.get_squad_count() == 12, "Cinematic capture must contain exactly 12 squads.")
	_expect(presenter.get_duplicate_slot_count() == 0, "Cinematic capture must not duplicate sword slots.")
	_expect(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final cinematic art must not retain the procedural sword overlay."
	)
	_expect(presenter.get_ui_coverage_estimate() < 0.10, "Cinematic UI must stay below ten percent.")
	_expect(not presenter.shows_qa_counter(), "Cinematic capture must not show QA counters.")
	await _save_capture(viewport, filename, LOGICAL_SIZE)
	if not legacy_filename.is_empty():
		await _save_capture(viewport, legacy_filename, LOGICAL_SIZE)
	await _release_viewport(viewport)


func _capture_interaction_focus_s00() -> void:
	var viewport := _make_viewport()
	var story: Control = STORY_SCENE.instantiate()
	viewport.add_child(story)
	await process_frame
	story.show_scene("S00", "관천협")
	story.set_chapter_label("서장 · 관천협")
	var dialogue_panel := story.get_node_or_null("DialoguePanel") as Control
	if dialogue_panel != null:
		dialogue_panel.hide()

	var director: InteractionDirector = INTERACTION_SCENE.instantiate()
	viewport.add_child(director)
	await process_frame
	var completion: Array[Dictionary] = []
	director.completed.connect(func(result: Dictionary) -> void: completion.append(result))
	director.start({
		"id": "INT-CH01-S00-FOCUS",
		"scene_id": "S00",
		"type": "FOCUS_POINT",
		"prompt_key": "CH01-INT-S00-FOCUS-PROMPT",
		"emotional_purpose": "이연이 위협보다 먼저 사람과 명령 구조 중 무엇을 읽는지 체감한다.",
		"expected_duration_sec": 3.0,
		"failure_state": null,
		"alternative_input": "keyboard_or_gamepad_focus_navigation",
		"replay_behavior": "auto_complete_with_saved_first_focus_or_skip",
		"on_complete_event": "interaction_completed",
		"points": [
			{"id": "refugees", "label": "피란민 행렬", "screen_position": [0.50, 0.60]},
			{"id": "commander", "label": "기병대 지휘관", "screen_position": [0.76, 0.37]},
		],
	}, {
		"prompt": "무엇을 먼저 본다",
		"settings": {"interaction_auto_complete": false},
		"replay_seen": false,
	})
	await process_frame
	await process_frame
	_expect(director.visible, "S00 focus interaction must remain visible before selection.")
	_expect(completion.is_empty(), "S00 focus interaction must not auto-complete during capture.")
	_expect(_count_visible_buttons(director) == 2, "S00 focus capture must show exactly two points.")
	_expect(not director.has_fail_state(), "S00 focus interaction must expose no fail state.")
	await _save_capture(viewport, "e2_interaction_focus_s00_1280x720.png", HD_SIZE)
	await _release_viewport(viewport)


func _capture_interaction_focus_s04() -> void:
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
	await _save_capture(viewport, "e2_interaction_focus_s04_1280x720.png", HD_SIZE)
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
	presenter.apply_camera_cue({"shot_id": "09_CONTROL"})
	_expect(presenter.get_visible_sword_count() == 9, "Authored S05 reveal must expose all nine slots.")
	await _save_capture(viewport, "e2_cinematic_9_reveal_1920x1080.png", LOGICAL_SIZE)
	presenter.show_final_state()
	_expect(presenter.get_sword_count() == 9, "S05 NINE_9 capture must contain exactly 9 swords.")
	_expect(presenter.get_squad_count() == 1, "S05 NINE_9 capture must contain exactly 1 squad.")
	_expect(presenter.get_duplicate_slot_count() == 0, "S05 NINE_9 capture must not duplicate sword slots.")
	_expect(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final S05 art must own its nine sword silhouettes without procedural duplicates."
	)
	_expect(presenter.get_ui_coverage_estimate() < 0.10, "S05 cinematic UI must stay below ten percent.")
	_expect(not presenter.shows_qa_counter(), "S05 cinematic capture must not show QA counters.")
	await _save_capture(viewport, "e2_cinematic_9_1920x1080.png", LOGICAL_SIZE)
	await _release_viewport(viewport)


func _capture_cinematic_north_gate() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present({
		"scene_id": "S09",
		"purpose": "네 번째 종에 북문을 멈추고 사람은 측문으로 들인다.",
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": "CIN-CH01-S09-DEPARTURE",
			"source_scene": "S09",
			"formation_template": "FULL_108",
			"sword_count": 108,
		},
	}, "full")
	presenter.show_final_state()
	_expect(presenter.get_sword_count() == 108, "S09 north-gate lock must contain exactly 108 swords.")
	_expect(presenter.get_squad_count() == 12, "S09 north-gate lock must contain exactly 12 squads.")
	_expect(presenter.get_duplicate_slot_count() == 0, "S09 north-gate lock must not duplicate sword slots.")
	_expect(presenter.get_formation_overlay_opacity() <= 0.01, "S09 final CG must own its sword silhouettes without procedural duplicates.")
	await _save_capture(viewport, "e2_cinematic_north_gate_lock_v4_1920x1080.png", LOGICAL_SIZE)
	await _save_capture(viewport, "e2_cinematic_north_gate_lock_v4_1280x720.png", HD_SIZE)
	await _release_viewport(viewport)


func _capture_consequence(route: String, image_path: String, filename: String) -> void:
	var viewport := _make_viewport()
	var screen: ConsequenceScreen = CONSEQUENCE_SCENE.instantiate()
	viewport.add_child(screen)
	await process_frame
	screen.show_result({
		"title": route.capitalize(),
		"image_path": image_path,
		"lines": ["사람", "정보", "공간", "검 회수 9/9"],
		"recall_text": "검 회수  9 / 9",
	})
	await create_timer(0.40, true, false, true).timeout
	_expect(screen.visible, "%s consequence screen must be visible." % route)
	await _save_capture(viewport, filename, HD_SIZE)
	await _release_viewport(viewport)


func _capture_chapter_end(route: String, filename: String) -> void:
	var viewport := _make_viewport()
	var screen: Control = CHAPTER_END_SCENE.instantiate()
	viewport.add_child(screen)
	await process_frame
	screen.show_completion({
		"completion_title": "제1장 완료",
		"completion_subtitle": "북문은 멎었다. 강진오가 첫 번째로 돌아왔다.",
		"choices": {"CH01-C06-PRIORITY": route},
		"flags": {"priority_choice": route, "swords_recalled": 9},
		"next_title": "다음 · 사라진 열두 번째 마차",
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
