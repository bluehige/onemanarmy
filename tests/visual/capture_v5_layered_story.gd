extends SceneTree

const STORY_SCENE := preload("res://scenes/story/story_screen.tscn")
const OUTPUT_DIR := "res://reports/mvp/evidence"
const LOGICAL_SIZE := Vector2i(1920, 1080)
const HD_SIZE := Vector2i(1280, 720)

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var output_path := ProjectSettings.globalize_path(OUTPUT_DIR)
	if DirAccess.make_dir_recursive_absolute(output_path) != OK:
		_fail("Could not create V5 evidence directory.")
		_finish()
		return
	await process_frame
	await _capture_s04_dialogue()
	await _capture_s02_hero()
	_finish()


func _capture_s04_dialogue() -> void:
	var viewport := _make_viewport()
	var story := STORY_SCENE.instantiate() as StoryScreen
	viewport.add_child(story)
	await process_frame
	story.show_scene("S04", "청우객잔")
	story.set_chapter_label("제1장 · 객잔의 구검")
	story.show_line({
		"text_id": "CH01-S04-V5-CAPTURE",
		"speaker_id": "lee_yeon",
		"speaker_name": "이연",
		"text": "잔을 내려놓아라. 두 번째 경고는 검이 한다.",
	}, true)
	var compositor := story.get_node("ShotCompositor") as VNShotCompositor
	_expect(compositor.get_current_shot_id() == "SHOT-CH01-S04-INN-CALM", "S04 capture must use its authored layered shot.")
	_expect(compositor.get_layer_count() == 4, "S04 capture must retain four independent overlay layers.")
	_expect(compositor.get_character_count() == 3, "S04 capture must retain its three character slots.")
	await create_timer(0.35, true, false, true).timeout
	await _save_capture(viewport, "e2_v5_story_s04_layered_1280x720.png")

	var more_button := story.find_child("MoreActions", true, false) as Button
	more_button.pressed.emit()
	await process_frame
	_expect((story.get_node("UtilityTray") as PanelContainer).visible, "Utility-tray capture must show its on-demand actions.")
	await _save_capture(viewport, "e2_v5_story_s04_utility_tray_1280x720.png")
	viewport.queue_free()
	await process_frame


func _capture_s02_hero() -> void:
	var viewport := _make_viewport()
	var story := STORY_SCENE.instantiate() as StoryScreen
	viewport.add_child(story)
	await process_frame
	story.show_scene("S02", "골목의 계약")
	story.set_chapter_label("제1장 · 죽은 자의 계약")
	var hero_step: Dictionary = {}
	var scene_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/ch01/s02.json"))
	if scene_value is Dictionary:
		for step_variant: Variant in (scene_value as Dictionary).get("steps", []):
			if step_variant is Dictionary and str((step_variant as Dictionary).get("id", "")) == "S02-010A":
				hero_step = (step_variant as Dictionary).duplicate(true)
				break
	hero_step["text"] = "조문탁은 청동패를 이연의 손바닥에 눌러 넣었다."
	story.show_line(hero_step, true)
	var compositor := story.get_node("ShotCompositor") as VNShotCompositor
	_expect(compositor.has_transient_hero(), "S02 capture must expose the real transient Hero CG.")
	_expect(compositor.get_layer_count() == 3, "S02 Hero capture must keep its two base characters plus one Hero layer.")
	await create_timer(0.35, true, false, true).timeout
	await _save_capture(viewport, "e2_v5_story_s02_hero_1280x720.png")
	viewport.queue_free()
	await process_frame


func _make_viewport() -> SubViewport:
	var viewport := SubViewport.new()
	viewport.size = LOGICAL_SIZE
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport


func _save_capture(viewport: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("%s produced an empty image." % filename)
		return
	image.resize(HD_SIZE.x, HD_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var nonblack := 0
	var samples := 0
	for y in range(0, image.get_height(), 16):
		for x in range(0, image.get_width(), 16):
			var color := image.get_pixel(x, y)
			if maxf(color.r, maxf(color.g, color.b)) > 0.02:
				nonblack += 1
			samples += 1
	_expect(float(nonblack) / float(maxi(samples, 1)) > 0.25, "%s must contain a rendered scene." % filename)
	var absolute_path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	var save_error := image.save_png(absolute_path)
	if save_error == OK:
		print("V5_STORY_CAPTURE_SAVED %s" % absolute_path)
	else:
		_fail("%s could not be saved (error %d)." % [filename, save_error])


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)


func _fail(message: String) -> void:
	_failures.append(message)
	push_error("[v5-story-capture] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("V5_STORY_CAPTURE_PASS")
		quit(0)
		return
	print("V5_STORY_CAPTURE_FAIL: %d failure(s)" % _failures.size())
	quit(1)
