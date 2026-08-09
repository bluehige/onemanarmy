extends SceneTree

const PresenterScene := preload("res://scenes/ui/cinematic_presenter.tscn")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var presenter: Control = PresenterScene.instantiate()
	root.add_child(presenter)
	await process_frame

	presenter.present(_payload("S00", 108), "full")
	_assert(
		presenter.get_formation_overlay_opacity() > 0.0,
		"Procedural formation traces should remain available during the authored reveal."
	)
	presenter.show_final_state()
	_assert(presenter.visible, "Presenter should be visible during a cinematic.")
	_assert(presenter.get_sword_count() == 108, "S00 should visibly instantiate exactly 108 swords.")
	_assert(presenter.get_squad_count() == 12, "S00 should visibly instantiate exactly 12 squads.")
	_assert(presenter.get_duplicate_slot_count() == 0, "108-sword presentation should have no duplicate slots.")
	_assert(presenter.get_visible_sword_count() == 108, "Final S00 frame should reveal all 108 authored swords.")
	_assert(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final S00 art should own the sword silhouettes without procedural duplicates."
	)
	_assert(not presenter.shows_qa_counter(), "Product cinematic UI must not expose QA counters.")
	_assert(presenter.get_ui_coverage_estimate() < 0.10, "Cinematic controls must occupy less than ten percent of the frame.")
	_assert("중복 슬롯" not in presenter.get_display_text(), "Duplicate-slot QA text must stay out of the product view.")

	presenter.present(_payload("S07A", 9), "summary")
	presenter.apply_camera_cue({"shot_id": "S05-LAMP"})
	_assert(presenter.get_visible_sword_count() == 0, "S05 lamp beat should precede sword reveal.")
	presenter.apply_camera_cue({"shot_id": "S05-INTERCEPT"})
	_assert(presenter.get_visible_sword_count() == 1, "S05 intercept beat should reveal one sword.")
	presenter.apply_camera_cue({"shot_id": "S05-PIN-STAIR"})
	_assert(presenter.get_visible_sword_count() == 3, "S05 pin beat should reveal three swords.")
	presenter.apply_camera_cue({"shot_id": "S05-CIVILIAN"})
	_assert(presenter.get_visible_sword_count() == 5, "S05 civilian beat should reveal five swords.")
	presenter.apply_camera_cue({"shot_id": "S05-CONTROL"})
	_assert(presenter.get_visible_sword_count() == 9, "S05 control beat should reveal all nine swords.")
	presenter.show_final_state()
	_assert(presenter.get_sword_count() == 9, "Inn cinematic should visibly instantiate exactly 9 swords.")
	_assert(presenter.get_squad_count() == 1, "Inn cinematic should use one nine-sword squad.")
	_assert(presenter.get_visible_sword_count() == 9, "Final inn frame should reveal all nine authored swords.")
	_assert(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final inn art should own its nine sword silhouettes without a second overlay."
	)
	_assert("요약" in presenter.get_display_text(), "Requested playback mode should be visible without QA copy.")
	for forbidden in ["랭크", "경험치", "명성", "콤보", "피해량"]:
		_assert(forbidden not in presenter.get_display_text(), "Cinematic UI should omit score/combat language: %s" % forbidden)

	presenter.dismiss()
	_assert(not presenter.visible, "Presenter should hide after completion.")
	_assert(presenter.get_sword_count() == 0, "Dismiss should release procedural blades.")
	presenter.queue_free()
	await process_frame
	_finish()


func _payload(scene_id: String, sword_count: int) -> Dictionary:
	return {
		"scene_id": scene_id,
		"purpose": "선택한 우선순위가 검대의 역할을 바꾼다.",
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": "TEST-%s" % scene_id,
			"source_scene": scene_id,
			"sword_count": sword_count,
		},
	}


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CINEMATIC_PRESENTER_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[cinematic-presenter-test] %s" % failure)
	quit(1)
