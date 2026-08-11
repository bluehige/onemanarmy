extends SceneTree

# GPU evidence command (headless uses the dummy renderer and cannot capture):
# & .\.tools\godot\Godot_v4.6.3-stable_win64_console.exe --path . \
#   --display-driver windows --resolution 1x1 --script res://tests/visual/capture_v5.gd

const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const STORY_SCENE := preload("res://scenes/story/story_screen.tscn")
const CINEMATIC_SCENE := preload("res://scenes/ui/cinematic_presenter.tscn")

const OUTPUT_DIR := "res://output/v5-evidence"
const LOGICAL_SIZE := Vector2i(1920, 1080)
const REVIEW_SIZE := Vector2i(1280, 720)

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("V5 capture requires the Windows display driver; use the GPU evidence command at the top of this script.")
		_finish()
		return
	var absolute_dir := ProjectSettings.globalize_path(OUTPUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK:
		_fail("Could not create %s (error %d)." % [absolute_dir, mkdir_error])
		_finish()
		return

	await process_frame
	await _capture_title()
	await _capture_story("S00", "관천협", {
		"text_id": "CH01-S00-001",
		"speaker_id": "",
		"speaker_name": "",
		"text": "강호에는 백팔 자루의 검을 검관에 싣고 떠도는 사내가 있다는 소문이 있다.",
	}, "v5_story_s00_opening_1280x720.png")
	await _capture_story("S04", "청우객잔", {
		"text_id": "CH01-S04-002",
		"speaker_id": "gwak_nosam",
		"speaker_name": "곽노삼",
		"text": "비를 피하려면 안으로 드시오. 검관은 처마 아래 두고.",
	}, "v5_story_s04_layered_1280x720.png")
	await _capture_story("S09", "백야성 북문", {
		"text_id": "CH01-S09-006",
		"speaker_id": "lee_yeon",
		"speaker_name": "이연",
		"text": "측문을 열어 사람부터 들이시오. 큰문은 내가 막는다.",
	}, "v5_story_s09_prelock_1280x720.png")
	await _capture_story("S02", "백야성 뒷골목", {
		"text_id": "CH01-S02-013",
		"speaker_id": "",
		"speaker_name": "",
		"text": "조문탁은 청동패와 봉인된 정정 원본을 이연의 손에 눌러 주었다.",
		"hero_cg_asset": "res://assets/art/ch01-v5/hero/CH01_CG_JO_MUNTAK_CONTRACT_v001.png",
	}, "v5_story_s02_hero_1280x720.png")
	await _capture_s00_motion()
	await _capture_s05_motion()
	await _capture_s09_sequence()
	_finish()


func _capture_title() -> void:
	var viewport := _make_viewport()
	var title: Control = TITLE_SCENE.instantiate()
	viewport.add_child(title)
	await process_frame
	title.configure(false, false)
	await _save(viewport, "v5_title_1280x720.png")
	await _release(viewport)


func _capture_story(scene_id: String, title: String, line: Dictionary, filename: String) -> void:
	var viewport := _make_viewport()
	var story: Control = STORY_SCENE.instantiate()
	viewport.add_child(story)
	await process_frame
	story.show_scene(scene_id, title)
	story.set_chapter_label("第一章 · 백여덟 이름")
	story.show_line(line, true)
	await create_timer(0.40, true, false, true).timeout
	await _save(viewport, filename)
	await _release(viewport)


func _capture_s00_motion() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present(_cinematic_payload("S00", "CIN-CH01-S00-CAPTURE", 108), "full")
	presenter.apply_camera_cue({"shot_id": "S00-12-CUT", "visible_blades": 108, "formation_animation_owned": true})
	presenter.apply_animation_cue({"phase": "curved_flight", "duration_sec": 1.4, "visible_blades": 108, "path_variant": "capture"})
	await create_timer(0.62, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s00_flight_1280x720.png")
	presenter.apply_animation_cue({"phase": "impact", "duration_sec": 0.45, "visible_blades": 108, "path_variant": "capture"})
	presenter.apply_vfx_cue({"id": "FX_INTERCEPT_STOP", "squad_index": 5})
	await create_timer(0.12, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s00_impact_1280x720.png")
	await _release(viewport)


func _capture_s05_motion() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present(_cinematic_payload("S05", "CIN-CH01-S05-COMMON", 9), "full")
	presenter.apply_camera_cue({"shot_id": "S05-NINE-CROSS", "visible_blades": 9, "formation_animation_owned": true})
	presenter.apply_animation_cue({"phase": "acceleration", "duration_sec": 1.2, "visible_blades": 9, "path_variant": "default"})
	await create_timer(0.45, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s05_nine_1280x720.png")
	await _release(viewport)


func _capture_s09_sequence() -> void:
	var viewport := _make_viewport()
	var presenter: Control = CINEMATIC_SCENE.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present(_cinematic_payload("S09", "CIN-CH01-S09-DEPARTURE", 108), "full")
	presenter.apply_camera_cue({"shot_id": "S09-BELL", "visible_blades": 0})
	await create_timer(0.24, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s09_prelock_1280x720.png")
	presenter.apply_camera_cue({"shot_id": "S09-NORTH-GATE-FINAL", "visible_blades": 108, "show_final_art": true})
	await create_timer(0.36, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s09_hero_1280x720.png")
	presenter.apply_camera_cue({"shot_id": "S09-SIDE-GATE", "visible_blades": 108, "return_to_layers": true})
	await create_timer(0.36, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s09_sidegate_1280x720.png")
	presenter.apply_camera_cue({"shot_id": "S09-ROGUE-WAGON", "visible_blades": 108})
	await create_timer(0.18, true, false, true).timeout
	await _save(viewport, "v5_cinematic_s09_rogue_wagon_1280x720.png")
	await _release(viewport)


func _cinematic_payload(scene_id: String, cinematic_id: String, sword_count: int) -> Dictionary:
	return {
		"scene_id": scene_id,
		"purpose": "작은 동작 뒤 공간의 질서가 바뀐다.",
		"settings": {
			"motion_reduction": false,
			"flash_reduction": false,
			"blade_trail_intensity": 0.85,
		},
		"cinematic": {
			"id": cinematic_id,
			"source_scene": scene_id,
			"sword_count": sword_count,
		},
	}


func _make_viewport() -> SubViewport:
	var viewport := SubViewport.new()
	viewport.name = "V5CaptureViewport"
	viewport.size = LOGICAL_SIZE
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	return viewport


func _save(viewport: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("%s produced an empty image." % filename)
		return
	image.resize(REVIEW_SIZE.x, REVIEW_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	var save_error := image.save_png(path)
	if save_error != OK:
		_fail("%s could not be saved (error %d)." % [filename, save_error])
	else:
		print("V5_CAPTURE_SAVED %s" % path)


func _release(viewport: SubViewport) -> void:
	viewport.queue_free()
	await process_frame


func _fail(message: String) -> void:
	_failures.append(message)
	push_error("[v5-capture] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("V5_CAPTURE_PASS")
		quit(0)
		return
	for failure in _failures:
		print("V5_CAPTURE_FAILURE %s" % failure)
	print("V5_CAPTURE_FAIL")
	quit(1)
